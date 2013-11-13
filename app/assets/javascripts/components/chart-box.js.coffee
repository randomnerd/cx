Cx.ChartBoxComponent = Ember.Component.extend
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
        selected : 2
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
        animation: false,
        type: 'candlestick'
        name: 'Exchange rate'
        data: [[0,0,0,0,0]]
        dataGrouping: { units: groupingUnits }
        zIndex: 2
      }, {
        animation: false,
        name  : 'Volume',
        type  : 'column',
        marker: { enabled: false },
        yAxis : 1,
        dataGrouping: {units: groupingUnits},
        data  : [0,0]
        zIndex: 1
      }]})
    @chart = $('#chart').highcharts()
    @series = @chart.series[0]
    @vseries = @chart.series[1]
    @series.setData([], false)
    @vseries.setData([], false)

  fill: ->
    $('#chart').highcharts()?.destroy()
    @initChart()
    items = @get('items.content')
    for citem in items
      item = citem._data
      points.push [ item.id, item.o, item.h, item.l, item.c ]
      vpoints.push [ item.id, item.v ]

    @series.addPoint(point, false, false, false) for point in points
    @vseries.addPoint(point, false, false, false) for point in vpoints
    @chart.redraw()

  updater: (->
    if @filltimer || !points.length
      clearTimeout(@filltimer)
      @filltimer = setTimeout ( =>
        @fill()
        @filltimer = undefined
      ), 100
      return

    clearTimeout(@timer)
    items = @get('items.content')
    return unless items.length

    item = items[items.length-1]._data
    points.push [ item.id, item.o, item.h, item.l, item.c ]
    vpoints.push [ item.id, item.v ]

    @timer = setTimeout ( =>
      for point in points
        if p = _.find(@series.points, (d) -> d.category == item.id)
          p.update(point, false, false, false)
        else
          @series.addPoint(point, false, false, false)
      for point in vpoints
        if p = _.find(@vseries.points, (d) -> d.category == item.id)
          p.update(point, false, false, false)
        else
          @vseries.addPoint(point, false, false, false)
      @chart.redraw()
    ), 100
  ).observes('items.@each.v')

  lastOne: (->
    # FIXME: workaround for observer not working
    @get('items.lastObject.v')
    return ''
  ).property('items.@each.v')
