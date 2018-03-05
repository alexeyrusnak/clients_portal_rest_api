create or replace package MCSF_API_TEST is

  -- Author  : A. STARSHININ
  -- Created : 04.12.2016 20:56:58
  -- Purpose : Пакет хранимых процедур для построения интернет-портала МКСФ

--*********************************************************************************************************************
-- Выдача списка заказов (orders)
--*********************************************************************************************************************
  type t_Order is record (
   id                  t_orders.ord_id%type,                 -- Код заказа (id)
   place_from          t_loading_places.address_source%type, -- Адрес отправки
   place_to            t_loading_places.address_source%type, -- Адрес назначения
   status              order_statuses.def%type,              -- Оперативный статус заказа
   status_id           order_statuses.orst_id%type,          -- Идентификатор статуса
   receivables         number(15,2),                         -- Сумма задолженности по заказу
   amount              number(15,2),                         -- Оплаченная сумма
   notification_count  number(15,2),                         -- Кол-во уведомлений 
   cargo_name          freights.def%type,                    -- Наименование груза
   contractor          clients.client_name%type,             -- Наименование грузоотправителя
   created_at          client_requests.ord_date%type,        -- Дата создания заказа
   date_from           t_loading_places.source_date_plan%type,-- Дата отправки заказа
   date_to             t_loading_places.source_date_plan%type,-- Дата прибытия заказа
   te_info             varchar2(500),                        -- Номер и тип ТЕ
   port_svh            ports.def%type,                       -- Порт СВХ
   cargo_country       countries.def%type                    -- Страна происхождения груза   
  );
  type tbl_Orders is table of t_Order;

  function Get_Orders(pClntId       client_requests.clnt_clnt_id%type,        -- ID Клиента
                      pDate_from    client_requests.ord_date%type,            -- Дата начала
                      pDate_to      client_requests.ord_date%type,            -- Дата окончания
                      pStatus_id    order_statuses.orst_id%type default Null,  -- Идентификатор статуса 
                      pSortId           Char default null,   -- Сортировка по ИД заказа 
                      pSortCreated_at   Char default null,   -- Сортировка по дате создани заказа
                      pSortDate_from    Char default null,   -- Сортировка по дате отправки заказа
                      pSortDate_to      Char default null,   -- Сортировка по дате прибытия заказа
                      pSortReceivables  Char default null    -- Сортировка по сумме задолженности
                      )
           return tbl_Orders pipelined parallel_enable;          
--*********************************************************************************************************************
-- Получение информации по заказу (orders_get)
--*********************************************************************************************************************
  type t_Ord is record (
   id                  t_orders.ord_id%type,                 -- Идентификатор заказа
   consignor           clients.client_name%type,             -- Грузоотправитель (Контрагент)
   consignee           clients.client_name%type,             -- Грузополучатель (Контрагент)
   created_at          client_requests.ord_date%type,        -- Дата создания заказа
   status              order_statuses.def%type,              -- Cтатус заказа
   messages            tbl_message,                          -- Сообщения менеджера 
   cargo               tbl_cargo,                            -- Информация о грузе 
   unit                tbl_unit,                             -- Информация о ТЕ
   doc                 tbl_doc,                              -- Прилагаемые документы 
   receivable_cost     invoices.price%type,                  -- Сумма задолженности
   amount_cost         invoices.price%type,                  -- Оплаченная сумма
   receivable_date     invoices.pay_date%type,               -- Срок погашения
   receivable_status   varchar2(500),                        -- Статус задолженности
   departure_port      ports.def%type,                       -- Порт отправления
   departure_country   countries.def%type,                   -- Страна отправления   
   container_type      conteiner_types.def%type,             -- Тип контейнера  
   container_prefix    conteiners.cont_index%type,           -- Префикс контейнера  
   container_number    conteiners.cont_number%type,          -- Номер контейнера
   date_shipment       t_loading_places.source_date_plan%type,-- Дата погрузки судна    
   date_transshipment  konosaments.pot_date%type,            -- Дата подхода в порт перевалки
   date_arrival        transport_time_table.arrival_date%type,-- Дата прибытия 
   date_upload         vouchers.voch_date%type,              -- Дата выгрузки
   date_export         cmrs.date_out%type,                   -- Дата вывоза
   date_submission     order_ways.date_plan%type,            -- Дата сдачи порожнего 
   arrival_city        cities.def%type,                      -- Город прибытия
   arrival_port        ports.def%type,                       -- Порт прибытия 
   arrival_ship        ships.def%type,                       -- Судно (Фидер) 
   gtd_number          gtds.gtd_number%type,                 -- ГТД номер
   gtd_date            gtds.gtd_date%type,                   -- Дата ГТД    
   gtd_issuance        gtds.date_out%type,                   -- Дата выпуска ГТД
   data_logisticians   varchar2(1000),                       -- Данные о логистах
   rummage_count       number(10),                           -- Количество таможенных досмотров   
   rummage_dates       tbl_rummage                           -- Даты досмотра 
 );
  type tbl_Ords is table of t_Ord;
  
  -- Функция выдачи данных по заказу
  -- Фильтр для отбора данных: ИД заказа и ИД Клиента. Цель - избежать ситуации выдачи данных по "чужим" заказам
  -- Т.е. пользователю портала выдаются заказы только его компании
  function fn_orders_get(pID t_orders.ord_id%type,
                         pClntId clients_dic.clnt_id%type)
           return tbl_Ords pipelined parallel_enable;  
  -- Функия проверки принадлежености заказа Клиенту, которому принадлежит текущий пользователь портала для Клиентов          
  function CheckOwnerOrder(pId t_orders.ord_id%type,
                           pClntId clients_dic.clnt_id%type) return boolean; 
  -- Данные о компании
  type t_company is record(
       id clients_dic.clnt_id%type,      -- ИД компании
       def clients_dic.client_name%type, -- Наименование компании
       tarif_plan tarif_plans.def%type,  -- Тарифный план компании
       debet_sum number(15,2),            -- Текущая задолженность в базовой валюте
       total_orders number,              -- общее количество заказов
       active_orders number,             -- количество активных заказов
       debts_count number,               -- количество не оплаченных заказов
       currency_code currencies.def%type  -- базовая валютп
       );
  type tbl_company is table of t_company; 
  -- Функция выдачи данных по компании                            
  function fn_company_get(pClntId clients_dic.clnt_id%type)
           return tbl_company pipelined parallel_enable;
  type t_company_contacts is record(
       person varchar2(4000),   -- ФИО контактного лица
       job client_contacts.job%type, -- должность
       phone client_contacts.phone%type, -- номер рабочего телефона
       mobile client_contacts.mobile%type -- номер мобильного телефона
       );
  type tbl_company_contacts is table of t_company_contacts;             
  function fn_company_contacts(pClntId clients_dic.clnt_id%type)
           return tbl_company_contacts pipelined parallel_enable;                                                               
----------------------------------------------------------------------------------------------------------------------
-- Справочники                 
type t_countries is record(
      id countries.cou_id%type,    -- ИД страны
      def countries.def%type           -- Страна
);
type t_regions is record(
      id continents.cntn_id%type,                     -- ИД континента
      region_name continents.region_name%type         -- Континет (регион)
);
type t_cities is record(
      id cities.city_id%type,     -- ИД города
      def cities.def%type         -- Город
);
type t_doc_types is record(
      id doc_types_dic.dctp_id%type,   -- идентификатор типа документа
      def doc_types.def%type           -- тип документа
);       
type tbl_countries is table of t_countries;
type tbl_regions is table of t_regions;
type tbl_cities is table of t_cities;
type tbl_doc_types is table of t_doc_types;
-- Функция возврата справочника стран
function fn_country_list return tbl_countries pipelined parallel_enable;
-- Функция возврата справочника регионов
function fn_region_list return tbl_regions pipelined parallel_enable;
-- Функция возврата справочника городов
function fn_cities_list return tbl_cities pipelined parallel_enable;
-- Функция возврата данных справочника типов документов
function fn_doc_types return tbl_doc_types pipelined parallel_enable;

-----------------------------------------------------------------------------
--- Работа с документами
--- Выдача документа  
type t_docs is record(
  id documents.dcmt_id%type,            -- Идентификатор документа
  order_id doc_links.ord_ord_id%type,   -- Идентификатор заказа
  type_doc doc_types_dic.dctp_id%type,  -- Идентификатор типа документа
  name_doc doc_types.def%type,          -- Наименование типа документа
  date_doc documents.doc_date%type,     -- Дата документа
  uploaded_at documents.navi_date%type, -- Дата загрузки
  owner documents.navi_user%type        -- Владелец документа
 );
type tbl_docs is table of t_docs; 
function fn_orders_doc(pID documents.dcmt_id%type,
                       pClntId clients_dic.clnt_id%type) return tbl_docs pipelined parallel_enable; 
function CreateDocument(pOrdId t_orders.ord_id%type,   -- принадлежность документа заказу
                        pClntId clients_dic.clnt_id%type, -- принадлежность документа клиенту
                        pDctpId doc_types_dic.dctp_id%type, -- тип документа
                        pDocnumber documents.doc_number%type default null, -- номер документа
                        pDocDate documents.doc_date%type default sysdate, -- дата документа
                        pTheme documents.theme%type default null,  -- тема документа
                        pShortContent documents.shrt_content%type default null, -- краткое описание документа (примечание) 
                        pAuthor documents.author%type default null -- автор документа
                        ) return number;
function UpdateDocument(pClntId clients_dic.clnt_id%type,     -- принадлежность документа клиенту, 
                        pDocId documents.dcmt_id%type,        -- Идентификатор документа
                        pDctpId doc_types_dic.dctp_id%type, -- тип документа
                        pDocnumber documents.doc_number%type default null, -- номер документа
                        pDocDate documents.doc_date%type default sysdate, -- дата документа
                        pTheme documents.theme%type default null,  -- тема документа
                        pShortContent documents.shrt_content%type default null, -- краткое описание документа (примечание) 
                        pAuthor documents.author%type default null -- автор документа
                        ) return boolean;
-- Удаление документа                         
function RemoveDocument(pClntId clients_dic.clnt_id%type,  -- принадлежность документа клиенту
                         pDocId documents.dcmt_id%type      -- идентификатор документа
                        ) return boolean;
-- Добавление файла в документ по заказу
function AddFileToDocument(pClntId clients_dic.clnt_id%type, -- принадлежность документа клиенту    
                  pDocId documents.dcmt_id%type,    -- идентификатор документа
                  pFileBody doc_stores.doc_data%type, -- содержимое файла для загрузки
                  pFileName doc_stores.file_name%type      -- имя файла
                  ) return integer;

procedure GetFile(pClntId in clients_dic.clnt_id%type,    -- принадлежность документа Клиенту
                  pFileId in doc_stores.dstr_id%type,     -- идентификатор выгружаемого файла
                  pFileBody out doc_stores.doc_data%type, -- содержимое выгружаемого файла
                  pFileName out doc_stores.file_name%type  -- имя файла
                 );
                                  
--*********************************************************************************************************************


--*********************************************************************************************************************
  -- Функция(и) для отчетов и графиков
--*********************************************************************************************************************

-- Отчет о заказах п.4.14.1 в ТЗ на разработку АПИ (операция report_order)
-- Ю.К. 22.03.2017
type t_da3num is record(              -- для графиков: аргумент - дата, 3 функции от даты - числа:
                          d   date
                        , n1  number
                        , n2  number
                        , n3  number
                        );
type tbl_da3num is table of t_da3num;                        
function ReportOrder( pClntId clients_dic.clnt_id%type  -- ID клиента
                    , pQuant  varchar2                  -- Квант группировки результатов {'year'|'month'|'week'|'day'}
                    , pStart  date                      -- Начало отчетного периода
                    , pStop   date                      -- Конец отчетного периода
                    ) return tbl_da3num                 -- Дата и три числа
                    pipelined;

--*********************************************************************************************************************
  -- Информация о контрагентах (contractor)
--*********************************************************************************************************************

-- Данные о контрагенте п.4.3.1 в ТЗ на разработку АПИ (операция contractors_get)
-- Ю.К. 14.04.2017
type t_contractor is record(
                            id            number
                          , name          clients.client_name%type
                          , address       clients.address%type
                          , address_type  number                                -- not provided
                          , type          clients.cltp_cltp_id%type
                          , city_id       cities.city_id%type
                          , city_name     cities.def%type
                          , person_id     client_contacts.clcn_id%type
                          , person_phone  client_contacts.phone%type
                          , person_email  client_contacts.email%type
                          --, person_name   varchar2(2000)                        -- first_name || last_name
                          , person_name   client_contacts.name%type
                          , person_for    varchar2(2000)                        -- not provided
                          );                    
function ContractorsGet(  pClntId       clients.clnt_id%type                    -- ID клиента
                        , pAddressType  number    default null                  -- почтовый, телефон и т.д. Не поддерживаем.
                        , pPersonFor    varchar2  default null                  -- за что отвечает. Не поддерживаем.
                        ) return        t_contractor;                          

-- Коллекции контрагентов п.4.3.2 в ТЗ на разработку АПИ (операция contractors)
-- Ю.К. 17.04.2017
type t_contractor_short is record(
                                    id            number
                                  , name          clients.client_name%type 
                                  , type          clients.cltp_cltp_id%type                          
                                  );
type tbl_contractor_short is table of t_contractor_short
;
function Contractors(
                      p_id_key      clients.clnt_id%type                        -- ключ поиска по ID контрагента
                    , p_id_opr      varchar2                  default '='       -- операция поиска по ID {'>' | '<' | '='}
                    , p_type_key    clients.cltp_cltp_id%type                   -- ключ _фильтра_ (равно) по типу контрагента
                    , p_name_key    clients.client_name%type                    -- ключ поиска по наименованию контрагента
                    , p_name_opr    varchar2                  default 'like'    -- операция поиска по имени (like - а что м.б. еще?)
                    ) 
                    return          tbl_contractor_short      pipelined;

-- Адрес доставки. Просмотр п.4.4.2 в ТЗ на разработку АПИ (операция delivery_points_get)
-- Ю.К. 18.04.2017
type t_delivery_point is record(
                                  id          number
                                , address     varchar2(2000)
                                , phone       varchar2(400)
                                , email       varchar2(400)
                                , name        varchar2(400)
                                );
function DeliveryPointsGet(p_id t_loading_places.ldpl_id%type) return t_delivery_point
;

-- Адрес доставки. Получение коллекции п.4.4.5 в ТЗ на разработку АПИ (операция delivery_points)
-- Ю.К. 20.04.2017
type tbl_delivery_points is table of t_delivery_point
;
function delivery_points(
            p_id_key      t_loading_places.ldpl_id%type         default null    -- ключ поиска по ID точки доставки
          , p_id_opr      varchar2                              default '='     -- операция поиска по ID {'>' | '<' | '='}
          , p_name_key    client_contacts.name%type             default '%'     -- ключ поиска по имени в точке доставки
          , p_name_opr    varchar2                              default 'like'  -- операция поиска по имени (like - а что м.б. еще?)
          , p_addr_key    t_loading_places.address_source%type  default '%'     -- ключ поиска по адресу точки доставки
          , p_addr_opr    varchar2                              default 'like'  -- операция поиска по адресу (like - а что м.б. еще?)
          , p_phone_key   client_contacts.phone%type            default '%'     -- ключ поиска по телефону в точке доставки
          , p_phone_opr   varchar2                              default 'like'  -- операция поиска по телефону (like - а что м.б. еще?)
          , p_email_key   client_contacts.email%type            default '%'     -- ключ поиска по телефону в точке доставки
          , p_email_opr   varchar2                              default 'like'  -- операция поиска по телефону (like - а что м.б. еще?)
          , p_sort_line   varchar2                              default 'id asc, name asc, address asc, phone asc, email asc'
          ) return        tbl_delivery_points pipelined
          ;

-- Задолженность. Получение коллекции. п. 4.10.1 в ТЗ на разработку АПИ (операция debts)
-- Ю.К. 24.04.2017
type t_debts is record(
                        id        number                                        -- ID заказа
                      , unit      varchar2(200)                                 -- Номер контейнера
                      , sum       number                                        -- Сумма задолженности в базовой валюте
                      , date_end  date                                          -- Дата оплаты счета
                      , status    varchar2(200)                                 -- Статус заказа
                      );
type tbl_debts is table of t_debts
;
function Debts(
                p_id          number                                            -- ID клиента
              , p_limit       number                                            -- Число возвращаемых строк
              , p_start_with  number  default 1                                 -- Номер первой возвращаемой строки
              ) return tbl_debts  pipelined
              ;
         

type t_shippers is record(
            clnt_id        clients.clnt_id%type                                         -- ID грузоотправителя
            , client_name      clients.client_name%type                                -- Название организации
            , official_city_id clients.city_city_id%type
            , official_city cities.def%type
            , official_address       clients.address%type                               -- Юридический адрес
            , official_address_zip  clients.zip%type                                          -- Почтовый индекс (юридический адрес)
            , actual_address   clients.address_fact%type                            -- Фактический адрес
            , actual_address_zip   clients.zip_fact%type                               -- Почтовый индекс (фактический адрес)
            );
type tbl_shippers is table of t_shippers
;


function getShippers return tbl_shippers  pipelined
        ;
	
type t_persons is record(
                        id        client_contacts.clcn_id%type                                       -- ID контактного лица
                      , name      varchar2(4000)                                 -- Полное имя контактного лица
                      , phone       client_contacts.phone%type                                        -- Телефон контактного лица
                      , email  client_contacts.email%type                                          -- Электронная почта
                      , position    client_contacts.job%type                                -- Должность занимаемая контактным лицом
					            , is_decide    client_contacts.lpr%type                                 -- Может принимать решение? 0 - нет 1 - да

                      );
type tbl_persons is table of t_persons
;


function getPersons(clnt_id number) return tbl_persons  pipelined
              ;

			             

end MCSF_API_TEST;
/
create or replace package body MCSF_API_TEST is

--*********************************************************************************************************************
-- Выдача списка заказов (orders)
--*********************************************************************************************************************
  function Get_Orders(pClntId       client_requests.clnt_clnt_id%type,        -- ID Клиента
                      pDate_from    client_requests.ord_date%type,            -- Дата начала
                      pDate_to      client_requests.ord_date%type,            -- Дата окончания
                      pStatus_id    order_statuses.orst_id%type default Null,  -- Идентификатор статуса 
                      pSortId           Char default null,   -- Сортировка по ИД заказа 
                      pSortCreated_at   Char default null,   -- Сортировка по дате создани заказа
                      pSortDate_from    Char default null,   -- Сортировка по дате отправки заказа
                      pSortDate_to      Char default null,   -- Сортировка по дате прибытия заказа
                      pSortReceivables  Char default null    -- Сортировка по сумме задолженности                      
                      )
           return tbl_Orders pipelined parallel_enable
 is   
 procedure ins_syslog is
   pragma autonomous_transaction;
 begin
      insert into sys_logs sl (slog_id,msg,appl_appl_id,apmt_apmt_id)
      values(slog_seq.nextval,to_char(pClntId) || ' ' || nvl(pSortId,'pSortId'),2,3);
      commit; 
 end;      
 begin
    ins_syslog;
    for cur in (
       select o.ord_id id,                     -- Код заказа (id)
              lp.address_source||' '||cit_lp.def||' '||cou_lp.def place_from,  -- Адрес отправки
              dp.address_source||' '||cit_dp.def||' '||cou_dp.def place_to,    -- Адрес назначения     
              ost.def status, -- Оперативный статус
              ost.orst_id status_id,      -- Идентификатор статуса
              nvl((select sum(round(id.price*id.quantity/i.base_rate, 2))
                   from invoice_details id,
                        invoices i 
                   where id.ord_ord_id   = o.ord_id
                     and id.invc_invc_id = i.invc_id
                     and i.intp_intp_id  = 1
                     and i.del_user is Null), 0) 
                     - 
              nvl((select sum(round(cp.summa_oper/i.base_rate, 2))
                          from invoice_details id,
                               invoices i,                                 
                               cash_prixods cp
                          where id.ord_ord_id   = o.ord_id
                            and id.invc_invc_id = i.invc_id
                            and i.intp_intp_id  = 1
                            and i.del_user is Null
                            and cp.indt_indt_id = id.indt_id
                            and cp.krnt_krnt_id is Null), 0) receivables, -- Сумма задолженности по заказу
              nvl((select sum(round(cp.summa_oper/i.base_rate, 2))
                          from invoice_details id,
                               invoices i,                                 
                               cash_prixods cp
                          where id.ord_ord_id   = o.ord_id
                            and id.invc_invc_id = i.invc_id
                            and i.intp_intp_id  = 1
                            and i.del_user is Null
                            and cp.indt_indt_id = id.indt_id
                            and cp.krnt_krnt_id is Null), 0) amount, -- Оплаченная сумма
              0 notification_count,            -- Кол-во уведомлений 
              fr.def cargo_name,               -- Наименование груза
              cl_otpr_o.client_name contractor,-- Наименование грузоотправителя
              cl.ord_date created_at,          -- Дата создания заказа
              lp.source_date_plan date_from,   -- Дата отправки заказа
              dp.source_date_plan date_to,     -- Дата прибытия заказа
              case when con.cont_number is Null 
                 then null
                 else con.cont_number||' ('||ctp.def||')' end te_info, -- Номер и тип ТЕ
              null port_svh,               -- Порт СВХ
              cou_lp.def cargo_country    -- Страна отправления груза              
        from t_orders o, 
             clrq_orders co, 
             client_requests cl,
             t_loading_places lp,
             t_loading_places dp,
             vOrd_Frgt vofr,
             freights fr,
             conteiners con,
             vOrder_Statuses_Last vsl,
             cities cit_dp,
             cities cit_lp,
             countries cou_dp,
             countries cou_lp,
             clients cl_otpr_o,
             conteiner_types ctp,
             order_statuses ost
       where cl.clnt_clnt_id   = pClntId 
         and cl.ord_date between pDate_from and pDate_to 
         and co.clrq_clrq_id   = cl.clrq_id 
         and o.ord_id          = co.ord_ord_id
         and o.cont_cont_id    = con.cont_id(+)
         and con.cntp_cntp_id  = ctp.cntp_id(+)
         and o.ord_id          = vsl.ord_ord_id(+)
         and vsl.orst_orst_id  = ost.orst_id(+)
         and (pStatus_id is Null or vsl.orst_orst_id = pStatus_id)
         and o.ord_id          = vofr.ord_ord_id(+)
         and vofr.frgt_frgt_id = fr.frgt_id(+)
         -- Грузоотправитель
         and o.ord_id          = lp.ord_ord_id(+)
         and lp.source_type(+) = 0
         and lp.ldpl_type(+)   = 0
         and lp.del_date(+) is Null
         and lp.source_clnt_id = cl_otpr_o.clnt_id(+)
         and lp.city_city_id   = cit_lp.city_id(+)
         and cit_lp.cou_cou_id = cou_lp.cou_id(+)
         -- Грузополучатель
         and o.ord_id          = dp.ord_ord_id(+)
         and dp.source_type(+) = 0
         and dp.ldpl_type(+)   = 1
         and dp.del_date(+) is Null
         and dp.city_city_id   = cit_dp.city_id(+)
         and cit_dp.cou_cou_id = cou_dp.cou_id(+)
         order by 
                  -- ИД заказа
                  case when pSortId = 'asc' then o.ord_id
                       else null end asc,
                  case when pSortId = 'desc' then o.ord_id
                       else null end desc,
                  -- Дата создания заказа       
                  case when pSortCreated_at = 'asc' then cl.ord_date
                       else null end asc,
                  case when pSortCreated_at = 'desc' then cl.ord_date
                       else null end desc,
                  -- Дата отправки заказа       
                  case when pSortDate_from = 'asc' then lp.source_date_plan
                       else null end asc,
                  case when pSortDate_from = 'desc' then lp.source_date_plan
                       else null end desc,
                  -- плановая дата прибыьия заказа       
                  case when pSortDate_to = 'asc' then dp.source_date_plan
                       else null end asc,
                  case when pSortDate_to = 'desc' then dp.source_date_plan
                       else null end desc,
                  -- Сумма задолженности по заказу       
                  case when pSortReceivables = 'asc' then receivables
                       else null end asc,
                  case when pSortReceivables = 'desc' then receivables
                       else null end desc                                       
      )
    loop
      pipe row (cur);
    end loop;
    return;      
 end;
--*********************************************************************************************************************
-- Получение информации по заказу (orders_get)
--*********************************************************************************************************************
 function fn_orders_get(pID t_orders.ord_id%type,
                        pClntId clients_dic.clnt_id%type)
           return tbl_Ords pipelined parallel_enable  
 is 
  vRow t_Ord;
  vRow_rummage t_rummage;
  vRow_doc t_doc;
  vRow_unit t_unit;
  vRow_cargo t_cargo;
  vRow_messages t_message;  
  i integer;
 begin
    for cur in (
      select o.ord_id id,-- Идентификатор заказа  
             cl_lp.client_name consignor,-- Грузоотправитель (Контрагент)        
             cl_dp.client_name consignee,-- Грузополучатель (Контрагент)        
             cl.ord_date created_at,-- Дата создания заказа       
             ost.def status,-- Cтатус заказа                
             nvl((select sum(round(id.price*id.quantity/i.base_rate, 2))
                   from invoice_details id,
                        invoices i 
                   where id.ord_ord_id   = o.ord_id
                     and id.invc_invc_id = i.invc_id
                     and i.intp_intp_id  = 1
                     and i.del_user is Null), 0) 
                     - 
              nvl((select sum(round(cp.summa_oper/i.base_rate, 2))
                          from invoice_details id,
                               invoices i,                                 
                               cash_prixods cp
                          where id.ord_ord_id   = o.ord_id
                            and id.invc_invc_id = i.invc_id
                            and i.intp_intp_id  = 1
                            and i.del_user is Null
                            and cp.indt_indt_id = id.indt_id
                            and cp.krnt_krnt_id is Null), 0) receivable_cost, -- Сумма задолженности 
             nvl((select sum(round(cp.summa_oper/i.base_rate, 2))
                          from invoice_details id,
                               invoices i,                                 
                               cash_prixods cp
                          where id.ord_ord_id   = o.ord_id
                            and id.invc_invc_id = i.invc_id
                            and i.intp_intp_id  = 1
                            and i.del_user is Null
                            and cp.indt_indt_id = id.indt_id
                            and cp.krnt_krnt_id is Null), 0) amount_cost, -- Оплаченная сумма     
             sysdate receivable_date,
             'Статус задолженности' receivable_status,-- Статус задолженности 
             'departure_port' departure_port,-- Порт отправления    
             'departure_country' departure_country,-- Страна отправления    
             ct.def container_type,-- Тип контейнера      
             con.cont_index container_prefix,-- Префикс контейнера    
             con.cont_number container_number,-- Номер контейнера  
             sysdate date_shipment,-- Дата погрузки судна         
             sysdate date_transshipment,-- Дата подхода в порт перевалки
             oc.arrival_date date_arrival,-- Дата прибытия       
             nvl(vd.voch_date, ow1.voch_date) date_upload,-- Дата выгрузки       
             ow3.date_out date_export,-- Дата вывоза       
             ow3.date_plan date_submission,-- Дата сдачи порожнего    
             cit_pod.def arrival_city,-- Город прибытия      
             p_pod.def arrival_port,-- Порт прибытия       
             s.def arrival_ship,-- Судно (Фидер)       
             g.gtd_number gtd_number,-- ГТД номер        
             g.gtd_date gtd_date,-- Дата ГТД    
             g.date_out gtd_issuance,-- Дата выпуска ГТД      
             'Данные о логистах' data_logisticians, --Данные о логистах
             (select count(co.chot_id)
              from check_outs co
              where co.ord_ord_id = o.ord_id) rummage_count     
        from t_orders o,
             clrq_orders co, 
             client_requests cl,  
             order_ways ow1,    
             order_ways ow3,    
             t_loading_places lp,
             t_loading_places dp,
             order_cnsm_mv oc,
             vord_gtd vgt,
             gtds g,
             vVouchers vd,
             vOrder_Statuses_Last vsl,
             conteiners con,
             cities cit_pod,
             ports p_pod,
             clients cl_lp,
             clients cl_dp,
             ships s,
             conteiner_types ct,
             order_statuses ost
       where o.ord_id = pID 
         and co.clrq_clrq_id   = cl.clrq_id 
         and cl.clnt_clnt_id   = pClntId      -- Отбор заказа не только по ИД заказа, но и по ИД клиента
         and o.ord_id          = co.ord_ord_id
         and o.ord_id          = vsl.ord_ord_id(+)
         and vsl.orst_orst_id  = ost.orst_id(+)
         and o.cont_cont_id    = con.cont_id(+)
         and con.cntp_cntp_id  = ct.cntp_id(+)
         and o.ord_id          = ow1.ord_ord_id(+)
         and ow1.orws_type(+)  = 1
         and ow1.del_user(+) is Null
         -- Грузоотправитель
         and o.ord_id          = lp.ord_ord_id(+)
         and lp.source_type(+) = 0
         and lp.ldpl_type(+)   = 0
         and lp.del_date(+) is Null
         and lp.source_clnt_id = cl_lp.clnt_id(+)
         -- Грузополучатель
         and o.ord_id          = dp.ord_ord_id(+)
         and dp.source_type(+) = 0
         and dp.ldpl_type(+)   = 0
         and dp.del_date(+) is Null
         and dp.source_clnt_id = cl_dp.clnt_id(+)
         -- Коносамент
         and o.ord_id            = oc.ord_id(+)
         and oc.pod_port_id      = p_pod.port_id(+)
         and oc.city_pod_id      = cit_pod.city_id(+)
         and oc.trsp_trsp_id     = s.trsp_id(+)         
         -- ДУ
         and o.ord_id            = vd.ord_ord_id(+)
         -- ГТД
         and o.ord_id            = vgt.ord_ord_id(+)
         and vgt.gtd_gtd_id      = g.gtd_id(+)
         -- Вывоз
         and o.ord_id            = ow3.ord_ord_id(+)
         and ow3.orws_type(+)    = 3
         and ow3.del_user(+) is Null
         )
    loop
       vRow.id := cur.id;                 -- Идентификатор заказа
       vRow.consignor := cur.consignor;   -- Грузоотправитель (Контрагент)
       vRow.consignee := cur.consignee;   -- Грузополучатель (Контрагент)
       vRow.created_at := cur.created_at; -- Дата создания заявки
       vRow.status := cur.status;         -- Текущий статус заказа 
       -- Сообщения менеджера  -------------------------
       vRow.messages := tbl_message();
       i := 0;
       for c1 in (select ms.mscm_id, ms.message_date,ms.send_to,ms.message_text,ms.ord_ord_id
                    from MESSAGES2CUSTOMERS ms
                   where ms.ord_ord_id = vRow.id) loop 
             vRow_messages := t_message(c1.mscm_id,         --Идентификатор сообщения
                                        c1.send_to,          -- Имя получателя
                                        c1.message_text,    -- Текст сообщение
                                        c1.message_date,    -- Дата создания сообщения
                                        'Отправлено',        -- Состояние сообщения
                                        c1.ord_ord_id);       -- Идентификатор заказа
             
             i := i + 1;                            
             vRow.messages.extend;
             vRow.messages(i) :=  vRow_messages;
       end loop;      
       -- Информация о грузе ---------------------------
       vRow.cargo := tbl_cargo();
       i := 0;
       for c2 in (select f.def, ofr.weight_brutto,nvl(ofr.weight,0) weight, ofr.unit_price,ofr.cur_cur_id,
                         ofr.volume,ofr.quantity,ofr.dimensions,nvl(lp.pcls_number,'Нет информации') pcls_number 
                    from freights f, order_freights ofr, loading_places lp
                   where lp.ord_ord_id = vRow.id and 
                         lp.del_user is Null and 
                         lp.ldpl_id = ofr.ldpl_ldpl_id and 
                         ofr.frgt_frgt_id = f.frgt_id) loop
               vRow_cargo := t_cargo(c2.def,   -- Наименование
                                     c2.weight_brutto, -- Вес брутто
                                     c2.weight, -- Вес нетто 
                                     c2.weight * c2.unit_price, -- Стоимость груза
                                     c2.cur_cur_id, -- Валюта
                                     c2.volume, -- Объем
                                     c2.dimensions, -- Размер (ВШД)
                                     trunc(sysdate), -- Дата готовности
                                     c2.pcls_number, -- Референс заказа
                                     tbl_point() ); -- Адрес выдачи 
               i := i +1 ;                      
               vRow.cargo.extend;
               vRow.cargo(i)    :=  vRow_cargo;
       end loop;
       -- Информация о ТЕ ------------------------------
       vRow.unit := tbl_unit();
       vRow_unit := t_unit('Тип ТЕ', -- Тип ТЕ
                           1, -- Вид транспорта 
                           'Комментарий по перевозке', -- Комментарий по перевозке
                           'Условия поставки ', -- Условия поставки 
                           'Особые отметки ', -- Особые отметки 
                           1, -- Требуется ли страхование (0 - не требуется, 1 - требуется)
                           tbl_cargo(), -- Массив грузов в ТЕ
                           ' Адрес выдачи' --  Адрес выдачи
                           );
       vRow.unit.extend;
       vRow.unit(1)    :=  vRow_unit;
       -- Прилагаемые документы ------------------------
       vRow.doc       := tbl_doc();
       vRow_doc := t_doc(12234, -- Идентификатор
                         'Наименование документа', -- Наименование документа
                         'Адрес файла', -- Адрес файла
                         'txt', -- Расширение файла
                         222, -- Размер файла
                         trunc(sysdate), -- Дата документа 
                         trunc(sysdate), -- Дата загрузки 
                         'Владелец документа' -- Владелец документа
                         );
       vRow.doc.extend;
       vRow.doc(1)    :=  vRow_doc;
       -------------------------------------------------
       vRow.receivable_cost := cur.receivable_cost;
       vRow.amount_cost := cur.amount_cost;
       vRow.receivable_date := cur.receivable_date;
       vRow.receivable_status := cur.receivable_status;
       vRow.departure_port := cur.departure_port;
       vRow.departure_country := cur.departure_country;
       vRow.container_type := cur.container_type;
       vRow.container_prefix := cur.container_prefix;
       vRow.container_number := cur.container_number;
       vRow.date_shipment := cur.date_shipment;
       vRow.date_transshipment := cur.date_transshipment;
       vRow.date_arrival := cur.date_arrival;
       vRow.date_upload := cur.date_upload;
       vRow.date_export := cur.date_export;
       vRow.date_submission := cur.date_submission;
       vRow.arrival_city := cur.arrival_city;
       vRow.arrival_port := cur.arrival_port;
       vRow.arrival_ship := cur.arrival_ship;
       vRow.gtd_number := cur.gtd_number;
       vRow.gtd_date := cur.gtd_date;
       vRow.gtd_issuance := cur.gtd_issuance;
       vRow.data_logisticians := cur.data_logisticians;
       vRow.rummage_count := cur.rummage_count;
       -- Даты досмотра  -------------------------------
       vRow.rummage_dates       := tbl_rummage();
       for rd in (select rownum rnum, co.chot_date
                  from check_outs co
                  where co.ord_ord_id = cur.id)
        loop
         vRow_rummage := t_rummage(rd.chot_date);
         vRow.rummage_dates.extend;
         vRow.rummage_dates(rd.rnum)    :=  vRow_rummage;
        end loop;
       -------------------------------------------------- 
      pipe row (vRow);      
    end loop;
    return;      
    
 end;  

----------------------------------------------------------
-- Функция возврата справочника стран
function fn_country_list return tbl_countries pipelined parallel_enable is
begin
  for cur in (select cou_id, def 
                from countries
                order by  def)
     loop
        pipe row(cur);
     end loop; 
     return;            
end;

-- Функция возврата справочника регионов
function fn_region_list return tbl_regions pipelined parallel_enable is
begin
  for cur in (select cn.cntn_id, cn.region_name 
                from continents cn
                order by  cn.region_name)
     loop
        pipe row(cur);
     end loop; 
     return;            
end; 

-- Функция возврата справочника городов
function fn_cities_list return tbl_cities pipelined parallel_enable is
begin
  for cur in (select c.city_id, c.def 
                from cities c
                order by c.def)
     loop
        pipe row(cur);
     end loop; 
     return;            
end;  

-- Функция возврата данных справочника типов документов
function fn_doc_types return tbl_doc_types pipelined parallel_enable is
begin
  for cur in (select dt.dctp_id, dt.def
                from doc_types dt
               where dt.doc_def = 0 and
                     dt.system_type = 0 
               order by dt.def)
      loop
        pipe row(cur);
      end loop;
      return;            
end;
----------------------------------------------------------------------------------------------------
---- Работа с документами
function fn_orders_doc(pID documents.dcmt_id%type,
                       pClntId clients_dic.clnt_id%type) return tbl_docs pipelined parallel_enable  is
begin
   for cur in (select d.dcmt_id id,       -- Идентификатор документа
                      dl.ord_ord_id order_id,   -- Идентификатор заказа
                      d.dctp_dctp_id type_doc,  -- Тип документа
                      dt.def name_doc,          -- Наименование типа документа
                      d.doc_date date_doc,      -- Дата документа
                      d.navi_date uploaded_at,     -- Дата загрузки
                      d.navi_user owner      -- Владелец документа (кто загрузил)
                from documents d, doc_links dl, doc_types dt,t_orders o, clrq_orders clrq, client_requests cl
                where d.dcmt_id = pId and
                      d.doc_state = 0 and  -- Только документы общего доступные для Клиентов
                      dl.dcmt_dcmt_id = d.dcmt_id and
                      o.ord_id = dl.ord_ord_id and
                      clrq.ord_ord_id = o.ord_id and
                      cl.clrq_id = clrq.clrq_clrq_id and
                      cl.clnt_clnt_id = pClntId and
                      dt.dctp_id = d.dctp_dctp_id
                      )
     loop
        pipe row(cur);
     end loop; 
     return;       
end;

--- Создание документа 
function CreateDocument(pOrdId t_orders.ord_id%type,   -- принадлежность документа заказу
                        pClntId clients_dic.clnt_id%type, -- принадлежность документа клиенту
                        pDctpId doc_types_dic.dctp_id%type, -- тип документа
                        pDocnumber documents.doc_number%type default null, -- номер документа
                        pDocDate documents.doc_date%type default sysdate, -- дата документа
                        pTheme documents.theme%type default null,  -- тема документа
                        pShortContent documents.shrt_content%type default null, -- краткое описание документа (примечание) 
                        pAuthor documents.author%type default null -- автор документа
                        ) return number is
DocId documents.dcmt_id%type;
pHoldId holding_dic.hold_id%type;                        
begin
  -- проверка принадлежности заказа Клиенту, которого представляет текущий пользователь портала
  if CheckOwnerOrder(pOrdId,pClntId) then
     begin
         select dcmt_seq.nextval into DocId from dual;
         -- Принадлежность клиента Холдингу
         select cl.hold_hold_id
           into pHoldId
           from clients_dic cl
          where cl.clnt_id = pClntId;
         -- Регистрация документа 
         insert into documents
               (dcmt_id,doc_number,doc_date,dctp_dctp_id,theme,shrt_content,
                author,navi_user,navi_date,doc_state,hold_hold_id)
         values(DocId,pDocnumber,pDocDate,pDctpId,pTheme,pShortContent,
                pAuthor,user,sysdate,0,pHoldId);
         -- фиксация связи документа с заказом
         insert into doc_links
                (dcln_id,dcmt_dcmt_id,ord_ord_id,navi_user,navi_date)
          values(dcln_seq.nextval,DocId,pOrdId,user,sysdate);
         commit;
         return DocId;
     end;            
  else
     return -1;
  end if;       
end;                        

-- Обновление данных документа
function UpdateDocument(pClntId clients_dic.clnt_id%type,     -- принадлежность документа клиенту, 
                        pDocId documents.dcmt_id%type,        -- Идентификатор документа
                        pDctpId doc_types_dic.dctp_id%type, -- тип документа
                        pDocnumber documents.doc_number%type default null, -- номер документа
                        pDocDate documents.doc_date%type default sysdate, -- дата документа
                        pTheme documents.theme%type default null,  -- тема документа
                        pShortContent documents.shrt_content%type default null, -- краткое описание документа (примечание) 
                        pAuthor documents.author%type default null -- автор документа
                        ) return boolean is
 pHoldId holding_dic.hold_id%type;  
 v_errm varchar2(2000); 
 pOrdId t_orders.ord_id%type;                      
begin
         -- Какому заказу принадлежит документ
         select dl.ord_ord_id
           into pOrdId
           from doc_links dl
         where dl.dcmt_dcmt_id = pDocId;  
         if CheckOwnerOrder(pOrdId,pClntId) then
            begin
               -- Принадлежность клиента Холдингу
               select cl.hold_hold_id
                 into pHoldId
                 from clients_dic cl
                where cl.clnt_id = pClntId;
               -- Обновление документа 
               update documents d
                  set d.doc_number = pDocnumber,
                      d.doc_date = pDocDate,
                      d.dctp_dctp_id = pDctpId,
                      d.theme = pTheme,
                      d.shrt_content = pShortContent,
                      d.author = pAuthor,
                      d.navi_user = user,
                      d.navi_date = sysdate,
                      d.hold_hold_id = pHoldId
                where d.dcmt_id = pDocId;
               commit;
               return true;
            end;
         else   
            -- Документ по заказу не принадлежит заданному Клиенту   
            return false;
         end if;   
exception
  when others then
    begin
      v_errm := SQLERRM;
      insert into sys_logs (slog_id,msg,log_date,appl_appl_id,apmt_apmt_id)
             values(slog_seq.nextval,v_errm,sysdate,20,1);
      commit;       
      return false;
    end;          
end; 

-- Удаление документа                         
function RemoveDocument(pClntId clients_dic.clnt_id%type,  -- принадлежность документа клиенту
                         pDocId documents.dcmt_id%type      -- идентификатор документа
                        ) return boolean is
 v_errm varchar2(2000); 
 pOrdId t_orders.ord_id%type;
begin
    -- Какому заказу принадлежит документ
    select dl.ord_ord_id
      into pOrdId
      from doc_links dl
     where dl.dcmt_dcmt_id = pDocId;  
    if CheckOwnerOrder(pOrdId,pClntId) then
       begin
         update documents d
            set d.del_user = user,
                d.del_date = sysdate
          where d.dcmt_id = pDocId;
         commit;
         return true;         
       end;
    else
      return false;
    end if; 
exception
  when others then
    begin
      v_errm := SQLERRM;
      insert into sys_logs (slog_id,msg,log_date,appl_appl_id,apmt_apmt_id)
             values(slog_seq.nextval,v_errm,sysdate,20,1);
      commit;       
      return false;
    end;                 
end;

-- Добавление файла в документ по заказу
function AddFileToDocument (pClntId clients_dic.clnt_id%type, -- принадлежность документа клиенту    
                  pDocId documents.dcmt_id%type,    -- идентификатор документа
                  pFileBody doc_stores.doc_data%type, -- содержимое файла для загрузки
                  pFileName doc_stores.file_name%type      -- имя файла
                  ) return integer is
FileId doc_stores.dstr_id%type;                  
begin
   select dstr_seq.nextval into FileId from dual;
   insert into doc_stores
          (dstr_id, dcmt_dcmt_id,file_name, doc_data,navi_user,navi_date)
     values(FileId,pDocId,pFileName,pFileBody,user,sysdate);
   return FileId;
exception
   when others then
     return -1;   
end;   

procedure GetFile(pClntId in clients_dic.clnt_id%type,    -- принадлежность документа Клиенту
                  pFileId in doc_stores.dstr_id%type,     -- идентификатор выгружаемого файла
                  pFileBody out doc_stores.doc_data%type, -- содержимое выгружаемого файла
                  pFileName out doc_stores.file_name%type  -- имя файла
                  ) is
begin
   pFileBody := documents_api.Get_Documents_Data(pFileId);
   select ds.file_name 
     into pFileName
     from doc_stores ds
    where ds.dstr_id = pFileId; 
exception
  when others then
    begin
      pFileBody := null;
      pFilename := null;
    end;    
end;                  

-- Функция выдачи данных по компании                            
function fn_company_get(pClntId clients_dic.clnt_id%type)
           return tbl_company pipelined parallel_enable is
vRow t_company;
TotalOrders number;
 function getTotalorders(pClntId in clients.clnt_id%type) return number is
 begin
   return 100;
 end; 
  
begin
  TotalOrders := getTotalorders(pClntId);
  for cur in (select cl.clnt_id, cl.client_name, tp.def tarif_plan,
                     0 debet_sum,TotalOrders, 0 active_orders, 0 debts_count,'RUR' currency_code
                from clients cl, client_histories ch,tarif_plans tp
               where cl.clnt_id = pClntId and
                     ch.clnt_clnt_id = cl.clnt_id and
                     sysdate between ch.start_date and ch.end_date and
                     tp.trpl_id = ch.trpl_trpl_id)
   loop
      pipe row(cur);
   end loop;
   return;           
end; 

-- Выдача контактных лиц компании
function fn_company_contacts(pClntId clients_dic.clnt_id%type)
           return tbl_company_contacts pipelined parallel_enable is
begin
  for cur in (select last_name || ' ' || first_name person,
                     job, phone, nvl(mobile,'No data') mobile
                from client_contacts
               where clnt_clnt_id = pClntId)
  loop
     pipe row(cur);
  end loop;
  return;               
end;                                                         
                                                                        
--*********************************************************************************************************************
  -- Функия проверки принадлежности заказа Клиенту, которому принадлежит текущий пользователь портала для Клиентов          
-- ********************************************************************************  
function CheckOwnerOrder(pId t_orders.ord_id%type,
                         pClntId clients_dic.clnt_id%type) return boolean is
ClntRqstId client_requests.clnt_clnt_id%type;
begin
  select cl.clnt_clnt_id
    into ClntRqstId
    from client_requests cl, clrq_orders co
   where co.ord_ord_id = pId and cl.clrq_id = co.clrq_clrq_id;
  if ClntRqstId = pClntId then
     return true;
  else
     return false;
  end if;       
exception
  when no_data_found then
    return false;    
end;

--*********************************************************************************************************************
  -- Функция(и) для отчетов и графиков
--*********************************************************************************************************************

-- Отчет о заказах п.4.14.1 в ТЗ на разработку АПИ (операция report_order)
-- Ю.К. 22.03.2017
function ReportOrder( pClntId clients_dic.clnt_id%type  -- ID клиента
                    , pQuant  varchar2                  -- Квант группировки результатов {'year'|'month'|'week'|'day'}
                    , pStart  date                      -- Начало отчетного периода
                    , pStop   date                      -- Конец отчетного периода
                    ) return tbl_da3num                 -- Дата и 3 числа
                    pipelined
is
  is_Quant_OK number default 0;
begin
  -- Проверка корректности кванта группировки:
  select decode(pQuant, 'year',1, 'month',1, 'week',1, 'day',1, 0) into is_Quant_OK from dual;
  if is_Quant_OK = 0 then return; end if;
  -- Смысловая часть:
  execute immediate 'alter session set nls_territory = ''russia'''; -- чтоб неделя начиналась с понедельника
  for cur in (
              select 
                trunc(r.ord_date, decode(pQuant, 'year','year', 'month','month', 'week','dy', 'day','dd'))  as x
              , count(*)                                                                                    as y_total
              , sum(nvl2(o.complete_date,0,1))                                                              as y_active
              , sum(nvl2(o.complete_date,1,0))                                                              as y_closed
              from 
                client_requests r
              , clrq_orders ro
              , t_orders o
              where ro.clrq_clrq_id = r.clrq_id and o.ord_id = ro.ord_ord_id
              and r.clnt_clnt_id = pClntId
              and r.ord_date between pStart and pStop
              and r.del_date is null and o.del_date is null
              group by trunc(r.ord_date, decode(pQuant, 'year','year', 'month','month', 'week','dy', 'day','dd'))
              order by x
              )
  loop
     pipe row(cur);
  end loop;
  return;
end ReportOrder;

--*********************************************************************************************************************
  -- Информация о контрагентах (contractor)
--*********************************************************************************************************************

-- Данные о контрагенте п.4.3.1 в ТЗ на разработку АПИ (операция contractors_get)
-- Ю.К. 14.04.2017
function ContractorsGet(  pClntId       clients.clnt_id%type                    -- ID клиента
                        , pAddressType  number    default null                  -- почтовый, телефон и т.д. Не поддерживаем.
                        , pPersonFor    varchar2  default null                  -- за что отвечает. Не поддерживаем.
                        ) return        t_contractor
is
  cont_rec    t_contractor;
  contact_id  client_contacts.clcn_id%type;                                     -- Решено брать ОДИН контакт - его ID.
begin
  begin
    select max(clcn_id) into contact_id 
    from client_contacts
    where clnt_clnt_id = pClntId;                                               -- Решил брать ПОСЛЕДНИЙ контакт.
  exception when no_data_found then                                             -- Нет контактов в таблице client_contacts_dic:
    select
        cl.clnt_id as id
      , cl.client_name as name
      , cl.address as address
      , null as address_type
      , cl.cltp_cltp_id as type
      , ci.city_id as city_id
      , ci.def as city_name
      , null as person_id
      , null as person_phone
      , null as person_email
      , null as person_name
      , null as person_for
      into cont_rec
      from clients cl, cities ci
      where ci.city_id = cl.city_city_id
      and cl.clnt_id = pClntId;
    return cont_rec;
  end;
  select
      cl.clnt_id as id
    , cl.client_name as name
    , cl.address as address
    , null as address_type
    , cl.cltp_cltp_id as type
    , ci.city_id as city_id
    , ci.def as city_name
    , co.clcn_id as person_id
    , co.phone as person_phone
    , co.email as person_email
    --, co.first_name || ' ' || co.last_name as person_name
    , co.name as person_name    
    , null as person_for
    into cont_rec
    from clients cl, cities ci, client_contacts co
    where ci.city_id = cl.city_city_id
    and co.clnt_clnt_id = cl.clnt_id
    and cl.clnt_id = pClntId
    and co.clcn_id = contact_id
    ;
  return cont_rec;
exception when no_data_found then                                               -- Вообще ничего нет:
  select 
      pClntId
    , null, null, null, null, null, null, null, null, null, null, null 
    into cont_rec from dual;
  return cont_rec;
end ContractorsGet;
                                    
-- Коллекции контрагентов п.4.3.2 в ТЗ на разработку АПИ (операция contractors)
-- Ю.К. 17.04.2017
/*
"filter": {
    "id": {
      "type": ">",
      "value": 10
    },
    "type": 1,
    "name": {
      "type": "like",
      "value": "tes%"
    }
  }
*/
function Contractors(
                      p_id_key      clients.clnt_id%type                        -- ключ поиска по ID контрагента
                    , p_id_opr      varchar2                  default '='       -- операция поиска по ID {'>' | '<' | '='}
                    , p_type_key    clients.cltp_cltp_id%type                   -- ключ _фильтра_ (равно) по типу контрагента
                    , p_name_key    clients.client_name%type                    -- ключ поиска по наименованию контрагента
                    , p_name_opr    varchar2                  default 'like'    -- операция поиска по имени (like - а что м.б. еще?)
                    ) 
                    return          tbl_contractor_short      pipelined
is
  is_ok number := 0;                                                            -- для проверки входных параметров управления
  v_sql varchar2(20000) := 'select clnt_id as id, client_name as name, cltp_cltp_id as type from clients ';
  type t_contr is ref cursor; cur t_contr;
  v_rec t_contractor_short;
begin
  select decode(p_id_opr, '>',1, '<',1, '=',1, 0) * decode(upper(p_name_opr), 'LIKE',1, 0) into is_ok from dual;
  if is_ok != 1 then return; end if;
  v_sql := v_sql 
    || ' where cltp_cltp_id = ' || p_type_key 
    || ' and clnt_id ' || p_id_opr || ' ' || p_id_key
    || ' and upper(client_name) ' || p_name_opr || ' upper(''' || p_name_key || ''')';
  open cur for v_sql;
  loop
    fetch cur into v_rec;
    exit when cur%notfound;
    pipe row(v_rec);
  end loop;
  close cur;
  return;
end Contractors;

-- Адрес доставки. Просмотр п.4.4.2 в ТЗ на разработку АПИ (операция delivery_points_get)
-- Ю.К. 18.04.2017
function DeliveryPointsGet(p_id t_loading_places.ldpl_id%type) return t_delivery_point
is
  v_rec t_delivery_point;
begin
  select 
      lp.ldpl_id as id
    , lp.address_source || ' ' || ci.def || ' ' || lp.zip || ' ' || co.def as address
    , ct.phone as phone
    , ct.email as email
    , ct.name as name
    into v_rec
    from t_loading_places lp, cities ci, countries co, client_contacts ct
    where ldpl_type = 1
    and ci.city_id = lp.city_city_id
    and co.cou_id = ci.cou_cou_id
    and ct.clcn_id = lp.clcn_clcn_id
    --and address_source is not null -- это отладка
    --and zip is not null -- это отладка
    and lp.ldpl_id = p_id;
  return v_rec;
exception when no_data_found then return v_rec;
end DeliveryPointsGet;

-- Адрес доставки. Получение коллекции п.4.4.5 в ТЗ на разработку АПИ (операция delivery_points)
-- Ю.К. 20.04.2017
function delivery_points(
            p_id_key      t_loading_places.ldpl_id%type         default null    -- ключ поиска по ID точки доставки
          , p_id_opr      varchar2                              default '='     -- операция поиска по ID {'>' | '<' | '='}
          , p_name_key    client_contacts.name%type             default '%'     -- ключ поиска по имени в точке доставки
          , p_name_opr    varchar2                              default 'like'  -- операция поиска по имени (like - а что м.б. еще?)
          , p_addr_key    t_loading_places.address_source%type  default '%'     -- ключ поиска по адресу точки доставки
          , p_addr_opr    varchar2                              default 'like'  -- операция поиска по адресу (like - а что м.б. еще?)
          , p_phone_key   client_contacts.phone%type            default '%'     -- ключ поиска по телефону в точке доставки
          , p_phone_opr   varchar2                              default 'like'  -- операция поиска по телефону (like - а что м.б. еще?)
          , p_email_key   client_contacts.email%type            default '%'     -- ключ поиска по телефону в точке доставки
          , p_email_opr   varchar2                              default 'like'  -- операция поиска по телефону (like - а что м.б. еще?)
          , p_sort_line   varchar2                              default 'id asc, name asc, address asc, phone asc, email asc'
          ) return        tbl_delivery_points pipelined
is
  is_ok number := 0;
  v_sql varchar2(20000) := '
select 
  lp.ldpl_id as id 
, lp.address_source || '' '' || ci.def || '' '' || lp.zip || '' '' || co.def as address 
, ct.phone as phone 
, ct.email as email 
, ct.name as name 
from t_loading_places lp, cities ci, countries co, client_contacts ct 
where ldpl_type = 1 
and ci.city_id = lp.city_city_id 
and co.cou_id = ci.cou_cou_id 
and ct.clcn_id = lp.clcn_clcn_id 
';
  type t_lp is ref cursor; cur t_lp;
  v_rec t_delivery_point;
begin
  select 
      decode(p_id_opr, '>',1, '<',1, '=',1, '>=',1, '<=',1, 0) 
    * decode(upper(p_name_opr), 'LIKE',1, 0) 
    * decode(upper(p_addr_opr), 'LIKE',1, 0) 
    * decode(upper(p_phone_opr), 'LIKE',1, 0) 
    * decode(upper(p_email_opr), 'LIKE',1, 0) 
    into is_ok from dual;
  if is_ok != 1 then return; end if;
  v_sql := v_sql 
    || ' and lp.ldpl_id ' || p_id_opr || ' ' || p_id_key
    || ' and nvl(upper(ct.name), '' '') ' || p_name_opr || ' upper(''' || p_name_key || ''')'
    || ' and nvl(upper(lp.address_source), '' '') ' || p_addr_opr || ' upper(''' || p_addr_key || ''')'
    || ' and nvl(upper(ct.phone), '' '') ' || p_phone_opr || ' upper(''' || p_phone_key || ''')'
    || ' and nvl(upper(ct.email), '' '') ' || p_email_opr || ' upper(''' || p_email_key || ''')'
    ;
  if p_sort_line is not null then
    v_sql := v_sql || ' order by ' || p_sort_line;
  end if;
  open cur for v_sql;
  loop
    fetch cur into v_rec;
    exit when cur%notfound;
    pipe row(v_rec);
  end loop;
  close cur;
  return;
exception when no_data_found then return;
end delivery_points;

-- Задолженность. Получение коллекции. п. 4.10.1 в ТЗ на разработку АПИ (операция debts)
-- Ю.К. 24.04.2017
/*
select * 
  from 
( select rownum rnum, a.*
    from (your_query) a
   where rownum <= :M )
where rnum >= :N;
in order to get rows n through m from "your query."
*/
function Debts(
                p_id          number                                            -- ID клиента
              , p_limit       number                                            -- Число возвращаемых строк
              , p_start_with  number  default 1                                 -- Номер первой возвращаемой строки
              ) return tbl_debts  pipelined
is
  N number := p_start_with;
  M number := p_start_with + p_limit - 1;
begin
  for cur in (
    select id, unit, sum, date_end, status from (select rownum rnum, id, unit, sum, date_end, status from 
    (
    select 
      o.ord_id as id
    , c.cont_index || ' ' || c.cont_number as unit
    , sum(round((id.quantity * id.price - id.oplacheno)/id.base_rate_det, 2)) as sum
    , i.pay_date as date_end
    , os.def as status
    from client_requests r, clrq_orders ro, t_orders o, conteiners c, invoice_details id, invoices i, vorder_statuses_last sl, order_statuses os
    where ro.clrq_clrq_id = r.clrq_id
    and o.ord_id = ro.ord_ord_id
    and o.del_date is null
    and c.cont_id = o.cont_cont_id
    and id.ord_ord_id = o.ord_id
    and i.invc_id = id.invc_invc_id
    and i.complete = 'N'
    and sl.ord_ord_id = o.ord_id
    and os.orst_id = sl.orst_orst_id
    and r.clnt_clnt_id = p_id
    group by o.ord_id, c.cont_index || ' ' || c.cont_number, i.pay_date , os.def
    order by id
    ) a
    where rownum <= M) where rnum >= N
  ) loop
    pipe row(cur);
  end loop;
  return;
end Debts;

function getShippers return tbl_shippers  pipelined
is
 
begin
  for cur in (
	select  c.clnt_id, 
      c.client_name,
      ci.city_id as official_city_id,
      ci.def as official_city,
      c.address as official_address,
      c.zip as official_address_zip,
      c.address_fact as actual_address,
      c.zip_fact as actual_address_zip
  from clients c, t_loading_places tlp, cities ci
  where tlp.source_clnt_id=c.clnt_id and ci.city_id=c.city_city_id and ldpl_type=1 
  
  ) loop
    pipe row(cur);
  end loop;
  return;
end getShippers;

                
function getPersons(clnt_id number) return tbl_persons  pipelined
is
 
begin
  for cur in (
 	select 
	c.clcn_id as id,
	c.last_name || ' ' || c.first_name || ' ' || c.middle_name as name,
	c.phone,
	c.email,
	c.job as position,
	c.lpr as is_decide
  from client_contacts c
  where c.clnt_clnt_id=clnt_id
  
  
  ) loop
    pipe row(cur);
  end loop;
  return;
end getPersons;
                                    
end MCSF_API_TEST;

 
/
