Cx.ChartBoxComponent = Ember.Component.extend
  defaultButton: 2
  init: -> Ember.run.later => @fillChart() if @get('pair.id')
  initChart: ->
    groupingUnits = [
      ['minute',[5, 10, 15, 30]]
      ['hour',[1, 2, 3, 4, 6, 8, 12]]
      ['day',[1,2,3]]
      ['week',[1,2]]
      ['month',[1, 3, 6]]
      ['year',null]
    ]

    Highcharts.setOptions({global: {useUTC: false}})
    $('#chart').highcharts()?.destroy()
    $('#chart').highcharts('StockChart', {
      rangeSelector:
        buttons : [
          { type : 'hour', count : 6, text : '6h' }
          { type : 'day', count : 1, text : '1D' }
          { type : 'day', count : 2, text : '2D' }
          { type : 'week', count : 1, text : '1W' }
          { type : 'month', count : 1, text : '1M' }
          { type : 'all', count : 1, text : 'All' }
        ]
        selected : @defaultButton
        inputEnabled : false
      tooltip: {
        valueDecimals: 8
      }
      plotOptions:
        candlestick: { color: '#b94a48', upColor: '#468847' }
        column: {
          color: '#EEE'
          tooltip:
            pointFormat: "<div>{series.name}: {point.y}</div>"
        }
      yAxis: [{
          min: 0
          labels: { style: { color: '#b94a48' } },
          title: { text: 'Rate', style: { color: '#CC3300' }
          }
        }, {
          min: 0
          title: { text: 'Volume', style: { color: '#4572A7' } },
          labels: { style: { color: '#4572A7' } },
          opposite: true
      }],
      series: [{
        type: 'candlestick'
        name: 'Exchange rate'
        data: [[0,0,0,0,0]]
        dataGrouping: { units: groupingUnits }
        zIndex: 2
      }, {
        name  : 'Volume',
        type  : 'column',
        marker: { enabled: false },
        yAxis : 1,
        dataGrouping: {units: groupingUnits},
        data  : [[0,0]]
        zIndex: 1
      }]})
    @chart = $('#chart').highcharts()
    @series = @chart.series[0]
    @vseries = @chart.series[1]

  fillChart: (->
    @initChart()
    @series.setData([], false)
    @vseries.setData([], false)
    @watchForUpdates(@get 'pair.id')
    $.ajax
      url: "/api/v2/trade_pairs/#{@get 'pair.id'}/chart_items"
      type: 'GET'
      success: (data) =>
        for item in data
          time = +(new Date(item.time.replace(' ','T')+"Z"))
          point = [
            time,
            parseInt(item.o) / Math.pow(10,8),
            parseInt(item.h) / Math.pow(10,8),
            parseInt(item.l) / Math.pow(10,8),
            parseInt(item.c) / Math.pow(10,8)
          ]
          vpoint = [ time, parseInt(item.v) / Math.pow(10,8) ]
          @series.addPoint(point, false, false, false)
          @vseries.addPoint(vpoint, false, false, false)

        rs = @chart.rangeSelector
        sel = rs.selected || @defaultButton
        @chart.redraw()
        rs.clickButton(sel, rs.buttonOptions[sel], true)
  ).observes('pair.id')

  watchForUpdates: (pairId) ->
    h.chartPusher?.unsubscribe()
    h.chartPusher = pusher.subscribe("chartItems-#{pairId}")
    h.chartPusher.callbacks._callbacks = {}
    h.chartPusher.unbind 'chartItem#update'
    h.chartPusher.bind 'chartItem#update', (item) =>
      time = +new Date(item.time)
      point = [
        time,
        item.o / Math.pow(10,8),
        item.h / Math.pow(10,8),
        item.l / Math.pow(10,8),
        item.c / Math.pow(10,8)
      ]
      vpoint = [ time, item.v / Math.pow(10,8) ]
      if p = _.find(@series.points, (d) -> d.category == time)
        p.remove()
      @series.addPoint(point, false)
      if p = _.find(@vseries.points, (d) -> d.category == time)
        p.remove()
      @vseries.addPoint(vpoint, false)
      @chart.redraw()
