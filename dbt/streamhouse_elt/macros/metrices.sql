{% macro gross_item_amount(quantity, unit_price) %}
    SUM({{quantity}} * {{unit_price}})
{% endmacro %}