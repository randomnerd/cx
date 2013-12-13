Cx.WithdrawalBoxComponent = Ember.Component.extend
  tfaCode: ''
  min_withdraw: 0.01
  actions:
    submit: ->
      $.ajax
        url: "/api/v2/currencies/#{@get 'currency.id'}/withdraw"
        type: "POST"
        data:
          amount: @get 'amount'
          address: @get 'address'
          totp: @get 'tfaCode'
        success: (data) =>
          $('#withdrawal-box').modal('hide')
          @set 'address', null
          @set 'amount', null
        error: (data) =>
          errors = data.responseJSON?.errors
          console.log errors
          if errors.totp
            $('#withdrawal-form #tfa-input').parent().addClass('has-error')
            Ember.run.next -> $('#withdrawal-form #tfa-input').focus()
    setFullAmount: ->
      @set 'amount', h.n2f @get('currency.balance.firstObject.amount')
      $('#withdrawal-form #amount-input').focus()
    addBookEntry: ->
      @set 'bookAddress', @get('address')
      @set 'newBookEntry', true
      Ember.run.later -> $('#book-name-input').focus()
    cancelBookEntry: -> @set 'newBookEntry', false
    toggleAddressBook: ->
      v = @get 'showAddressBook'
      if v
        @set 'bookAddress', ''
        @set 'bookName', ''
      else
        @set 'bookAddress', @get('address')
        Ember.run.later -> $('#book-name-input').focus()
      @set 'showAddressBook', !v
    pickBookAddress: (address) ->
      @set 'address', address
      @set 'showAddressBook', false
      Ember.run.later -> $('#amount-input').focus()
    deleteBookEntry: (item) ->
      item.deleteRecord()
      item.save()
    editBookEntry: (item) ->
      @set 'bookEdit', item
      @set 'bookName', item.get 'name'
      @set 'bookAddress', item.get 'address'
      Ember.run.later -> $('#book-name-input').focus()
    cancelBookEntry: ->
      @set 'bookAddress', ''
      @set 'bookName', ''
      if @get 'bookEdit'
        @set 'bookEdit', null
      else
        @set 'showAddressBook', false
    saveBookEntry: ->
      if rec = @get('bookEdit')
        rec.set('name', @get 'bookName')
        rec.set('address', @get 'bookAddress')
        rec.save()
      else
        rec = @store.createRecord 'addressBookItem',
          name: @get 'bookName'
          address: @get 'bookAddress'
          currency: @get 'currency.content'
        rec.save()
      @set 'bookEdit', null
      @set 'bookAddress', ''
      @set 'bookName', ''

  allowWithdraw: (->
    a = parseFloat(@get('amount'))
    ba = h.n2f @get('currency.balance.firstObject.amount')
    return unless @get('address')?.length > 30
    return if @get('user.totp_active') && @get('tfaCode').length < 6
    a <= ba && a >= @get('min_withdraw')
  ).property('amount', 'currency.balance.firstObject.amount', 'user.totp_active', 'tfaCode', 'address')

  allowSaveEntry: (->
    @get('bookAddress') && @get('bookName')
  ).property('bookAddress', 'bookName')

  bookItems: (->
    @store.filter 'addressBookItem', (o) =>
      o.get('currency.id') == @get('currency.id')
  ).property('currency.id')
