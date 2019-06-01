using Test
using PlotAxes
using Dates
using AxisArrays
using Pkg
using Unitful

macro handle_RCall_failure(body)
  quote
    try
      $(esc(body))
    catch e
      if e isa ErrorException && Sys.iswindows() &&
        startswith(e.msg,"Failed to precompile RCall ")
        @warn "Failed to properly install RCall; currently fails on Windows "*
        "when you use Conda to install R. You can fix this by manually "*
        "installing and downloading R and then typing ]build RCall at the "*
        "julia REPL."
      else
        rethrow(e)
      end
    end
  end
end

@testset "PlotAxes" begin

@testset "Can generate plotable data" begin
  data = AxisArray(rand(10,10,2,2),:a,:b,:c,:d)
  df, = PlotAxes.asplotable(data)
  @test size(df,1) == length(data)
  @test :a ∈ names(df)
  @test :b ∈ names(df)
  @test :c ∈ names(df)
  @test :d ∈ names(df)
  @test :value ∈ names(df)

  data = AxisArray(rand(10,10,2),:a,:b,:c)
  df, = PlotAxes.asplotable(data)
  @test size(df,1) == length(data)

  data = AxisArray(rand(10,10),:a,:b)
  df, = PlotAxes.asplotable(data)
  @test size(df,1) == length(data)

  data = AxisArray(rand(10),:a)
  df, = PlotAxes.asplotable(data)
  @test size(df,1) == length(data)

  data = AxisArray(rand(10),Axis{:time}(DateTime(1961,1,1):Day(1):DateTime(1961,1,10)))
  df, = PlotAxes.asplotable(data)
  @test size(df,1) == length(data)

  data = AxisArray(rand(10),Axis{:time}(DateTime(1961,1,1):Day(1):DateTime(1961,1,10)))
  df, = PlotAxes.asplotable(data,quantize=(5,))
  @test size(df,1) == 5

  data = AxisArray(rand(10),Axis{:time}(range(0u"s",1u"s",length=10)))
  df, = PlotAxes.asplotable(data,quantize=(5,))
  @test size(df,1) == 5

  df, = PlotAxes.asplotable(rand(10,10),quantize=(5,5))
  @test size(df,1) == 25
end

@testset "Can use backends" begin
  data = AxisArray(rand(10,10,2,2),:a,:b,:c,:d)

  @test_throws ErrorException PlotAxes.set_backend!(:impossible_bob)

  using Gadfly
  plotaxes(data)
  @test PlotAxes.current_backend[] == :gadfly

  using VegaLite
  plotaxes(data)
  @test PlotAxes.current_backend[] == :vegalite

  @handle_RCall_failure begin
    using RCall
    plotaxes(data)
    @test PlotAxes.current_backend[] == :ggplot2
  end

  alldata = [
    AxisArray(rand(10,10,2),:a,:b,:c),
    AxisArray(rand(10,10),:a,:b),
    AxisArray(rand(10),:a)
  ]
  for d in alldata
    for b in PlotAxes.list_backends()
      PlotAxes.set_backend!(b)
      result = plotaxes(d)
      @test result != false
    end
  end
end

end
