using Test
using PlotAxes
using Dates
using AxisArrays
using Pkg
using Unitful

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

  using Gadfly
  plotaxes(data)
  @test PlotAxes.current_backend[] == :gadfly

  using VegaLite
  plotaxes(data)
  @test PlotAxes.current_backend[] == :vegalite

  using RCall
  plotaxes(data)
  @test PlotAxes.current_backend[] == :ggplot2

  alldata = [
    AxisArray(rand(10,10,2),:a,:b,:c),
    AxisArray(rand(10,10),:a,:b),
    AxisArray(rand(10),:a)
  ]
  for d in alldata
    for b in [:ggplot2,:vegalite,:gadfly]
      PlotAxes.set_backend!(b)
      result = plotaxes(d)
      @test result != false
    end
  end
end
