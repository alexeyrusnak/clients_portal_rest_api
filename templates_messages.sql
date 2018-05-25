create or replace view templates_messages as
select
       tm_id,
       cast(substr(multilang.get_language_cap(def),1,500) as varchar(500)) def,
       def def_xml,
       appl_appl_id,
       cast(substr(multilang.get_language_cap(messages_text),1,4000) as varchar(4000)) messages_text,
       messages_text messages_text_xml,
       store_days,
       del_date,
       del_user,
     is_order
from templates_messages_dic;
