prompt Importing table templates_messages...
set feedback off
set define off
insert into templates_messages (TM_ID, DEF, DEF_XML, APPL_APPL_ID, MESSAGES_TEXT, MESSAGES_TEXT_XML, STORE_DAYS, DEL_DATE, DEL_USER, IS_ORDER)
values (tm_seq.nextval, '������ <����� ������> ������� � ������', '<CAP><RU>������ <����� ������> ������� � ������</RU><EN>Zajavka <nomer zajavki> prinjata v rabotu</EN></CAP>', 21, '������ ����! 

������ <����� ������> �� ��������� ������ ����� "<����>" ������� � ������ <����>. 

� ���������, 
��� "���-����������', '<CAP><RU>������ ����! 

������ <����� ������> �� ��������� ������ ����� "<����>" ������� � ������ <����>. 

� ���������, 
��� "���-����������</RU><EN>Dobryjj den`! 

Zajavka <nomer zajavki> na obrabotku Vashego gruza "<gruz>" prinjata v rabotu <data>. 

S uvazheniem, 
OOO "MKS-forvarding</EN></CAP>', 1, null, null, 0);

insert into templates_messages (TM_ID, DEF, DEF_XML, APPL_APPL_ID, MESSAGES_TEXT, MESSAGES_TEXT_XML, STORE_DAYS, DEL_DATE, DEL_USER, IS_ORDER)
values (tm_seq.nextval, '��������� ������� ������ <����� ������>', '<CAP><RU>��������� ������� ������ <����� ������></RU><EN>Izmenenie statusa zakaza <nomer zajavki></EN></CAP>', 21, '��������� ������� ������ <����� ������>

��������� ������, 

<����> ������ ������ ������ ������� c "<������ ������>" �� "<����� ������>"', '<CAP><RU>��������� ������� ������ <����� ������>

��������� ������, 

<����> ������ ������ ������ ������� c "<������ ������>" �� "<����� ������>"</RU><EN>Izmenenie statusa zakaza <nomer zajavki>

Uvazhaemyjj klient, 

<data> status Vashego zakaza izmenen c "<staryjj status>" na "<novyjj status>"</EN></CAP>', 1, null, null, null);

commit;

prompt Done.

