module ApplicationHelper
  include ActionView::Helpers::NumberHelper
  def n2f(n)
    number_with_precision(n.to_f / 10 ** 8, precision: 8, strip_insignificant_zeros: true)
  end
end
