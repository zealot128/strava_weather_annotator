module ApplicationHelper
  def number_to_unit(number, unit, opts = {})
    opts = opts.merge(unit: unit, format: "%n&nbsp;%u".html_safe)
    number_to_currency number, opts
  end
end
