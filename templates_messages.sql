prompt Importing table templates_messages...
set feedback off
set define off
insert into templates_messages (TM_ID, DEF, DEF_XML, APPL_APPL_ID, MESSAGES_TEXT, MESSAGES_TEXT_XML, STORE_DAYS, DEL_DATE, DEL_USER, IS_ORDER)
values (tm_seq.nextval, 'Заявка <номер заявки> принята в работу', '<CAP><RU>Заявка <номер заявки> принята в работу</RU><EN>Zajavka <nomer zajavki> prinjata v rabotu</EN></CAP>', 21, 'Добрый день! 

Заявка <номер заявки> на обработку Вашего груза "<груз>" принята в работу <дата>. 

С уважением, 
ООО "МКС-форвардинг', '<CAP><RU>Добрый день! 

Заявка <номер заявки> на обработку Вашего груза "<груз>" принята в работу <дата>. 

С уважением, 
ООО "МКС-форвардинг</RU><EN>Dobryjj den`! 

Zajavka <nomer zajavki> na obrabotku Vashego gruza "<gruz>" prinjata v rabotu <data>. 

S uvazheniem, 
OOO "MKS-forvarding</EN></CAP>', 1, null, null, 0);

insert into templates_messages (TM_ID, DEF, DEF_XML, APPL_APPL_ID, MESSAGES_TEXT, MESSAGES_TEXT_XML, STORE_DAYS, DEL_DATE, DEL_USER, IS_ORDER)
values (tm_seq.nextval, 'Изменение статуса заказа <номер заявки>', '<CAP><RU>Изменение статуса заказа <номер заявки></RU><EN>Izmenenie statusa zakaza <nomer zajavki></EN></CAP>', 21, 'Изменение статуса заказа <номер заявки>

Уважаемый клиент, 

<дата> статус Вашего заказа изменен c "<старый статус>" на "<новый статус>"', '<CAP><RU>Изменение статуса заказа <номер заявки>

Уважаемый клиент, 

<дата> статус Вашего заказа изменен c "<старый статус>" на "<новый статус>"</RU><EN>Izmenenie statusa zakaza <nomer zajavki>

Uvazhaemyjj klient, 

<data> status Vashego zakaza izmenen c "<staryjj status>" na "<novyjj status>"</EN></CAP>', 1, null, null, null);

commit;

prompt Done.

