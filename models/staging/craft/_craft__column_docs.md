
{% docs is_entity_deleted %}
True if the entity either has a deleted timestamp in Taco/Craft or the record was deleted and detected by dbt snapshots.
{% enddocs %}


{% docs is_program_district_auto_add %}
Boolean: True if the program is always included with products and added by default to new districts.
{% enddocs %}


{% docs program_license_type %}
| Value             | Meaning                       |
|-------------------|------------------------------|
| Perpetual | The program does not expire or need to be renewed. Applies to supplemental programs. |
| Renewable     | The program has a defined expiration date, and districts need to renew for content access. Applies to typical programs, such as Frog Street Pre-K. |

{% enddocs %}


{% docs program_market_specific %}
Programs that had content customized for a state or target market, such as "Louisiana"
{% enddocs %}


{% docs program_order_number %}
Used for ordering programs in the UI.
{% enddocs %}


{% docs program_release_year %}
The year that the Lilypad digital program transitioned to Live. This is not the content release date or the copyright date.
{% enddocs %}


{% docs resource_author_id %}
User ID of the author of the record; not editable in UI.
{% enddocs %}


{% docs resource_cloned_from %}
`program_id` that the resource was copied from when it was created.
{% enddocs %}

{% docs resource_provider_id %}
Joins with the `resource_providers` table and identifies the type of provider for the resource we're embedding.
Examples of resource providers: Sprout Video, URL, Youtube, Vimeo.
{% enddocs %}


{% docs resource_type %}
The type of the resource assigned to it in Craft.
Values are: activity, audio (music), book, document, image, text, web link, video
{% enddocs %}