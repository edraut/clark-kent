
resource_option_struct = Struct.new(:id, :name)

ClarkKent.config({
  resource_options: [
    {id: 'Order', name: 'Order'}
  ],
  user_class_name: 'User',
  other_sharing_scopes: [['Department',:department]],
  base_controller_name: '::ApplicationController'
})
