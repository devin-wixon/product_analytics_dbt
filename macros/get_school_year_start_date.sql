{% macro get_school_year_start_date(date_column) %}
{#-
  Macro to calculate the school year start date for a given date column.
  Returns the July 1st date for the school year that contains the given date.

  For semantic models, use this inline expression instead (macros not supported):

  expr: |
    case
      when month(client_event_date) >= {{ var('school_year_start_month') }}
      then date_from_parts(year(client_event_date), {{ var('school_year_start_month') }}, {{ var('school_year_start_day') }})
      else date_from_parts(year(client_event_date) - 1, {{ var('school_year_start_month') }}, {{ var('school_year_start_day') }})
    end
-#}
  case
    when month({{ date_column }}) >= {{ var('school_year_start_month') }}
    then date_from_parts(year({{ date_column }}), {{ var('school_year_start_month') }}, {{ var('school_year_start_day') }})
    else date_from_parts(year({{ date_column }}) - 1, {{ var('school_year_start_month') }}, {{ var('school_year_start_day') }})
  end
{% endmacro %}