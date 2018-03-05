create or replace package MCSF_API is

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
   date_closed         t_orders.complete_date%type,          --  Дата завершения заказа. Возвращается типом string
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
/*
-- Invoices. YK, 22.07.2014:
type t_ords_in_invc is record (id t_orders.ord_id%type);
type tbl_ords_in_invc is table of t_ords_in_invc; -- Массив идентификаторов заказов, включенных в этот инвойс

type t_invcs_in_ord is record (
    id        invoices.invc_id%type
  , total     invoices.price%type
  , paid      invoice_details.oplacheno%type
  , pay_to    date
  , currency  currencies.def%type
  --, orders    tbl_ords_in_invc
  );
type tbl_invcs_in_ord is table of t_invcs_in_ord; -- Массив счетов по заказу
-- YK.
*/

 type t_Ord is record (
   id                  t_orders.ord_id%type,                 -- Идентификатор заказа
   consignor           clients.client_name%type,             -- Грузоотправитель (Контрагент)
   consignee           clients.client_name%type,             -- Грузополучатель (Контрагент)
   created_at          client_requests.ord_date%type,        -- Дата создания заказа
   date_closed         t_orders.complete_date%type,          -- Дата завершения заказа
   -- status              order_statuses.def%type,              -- Cтатус заказа
   messages            tbl_message,                          -- Сообщения менеджера 
   cargo               tbl_cargo,                            -- Информация о грузе 
   unit                tbl_unit,                             -- Информация о ТЕ
   doc                 tbl_order_docs,                       -- Прилагаемые документы 
   -- receivable_cost     invoices.price%type,                  -- Сумма задолженности
   -- amount_cost         invoices.price%type,                  -- Оплаченная сумма
   -- receivable_date     invoices.pay_date%type,               -- Срок погашения
   -- receivable_status   varchar2(500),                        -- Статус задолженности
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
 --  arrival_ship        ships.def%type,                       -- Судно (Фидер) 
   gtd_number          gtds.gtd_number%type,                 -- ГТД номер
   gtd_date            gtds.gtd_date%type,                   -- Дата ГТД    
   gtd_issuance        gtds.date_out%type,                   -- Дата выпуска ГТД
  -- data_logisticians   varchar2(1000),                       -- Данные о логистах
   rummage_count       number(10),                           -- Количество таможенных досмотров   
   rummage             tbl_rummage,                           -- Даты и виды досмотра 
-- YK, 22.07.2017:
   invoices            tbl_invcs_in_ord                      -- Массив счетов по заказу
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
       client_name clients_dic.client_name%type, -- Наименование компании
       phone  varchar2(100),             -- Рабочий телефон компании
       plan tarif_plans.def%type,        -- Тарифный план компании
       total_orders number               -- Количество заказов за историю работы компании
       );
  type tbl_company is table of t_company; 
  -- Функция выдачи данных по компании                            
  function fn_company_get(pClntId clients_dic.clnt_id%type)
           return tbl_company pipelined parallel_enable;
  type t_company_contacts is record(
       fio varchar2(4000),   -- ФИО контактного лица
       job client_contacts.job%type, -- должность
       phone client_contacts.phone%type, -- номер рабочего телефона
       mobile client_contacts.mobile%type -- номер мобильного телефона
       );
  type tbl_company_contacts is table of t_company_contacts;             
  function fn_company_contacts(pClntId clients_dic.clnt_id%type)
           return tbl_company_contacts pipelined parallel_enable;   
           
  -- Функция выдачи данных о дебиторской задолженности в по валютам счетов
  type t_sum is record(
       currency currencies.code%type, -- Валюта задолженности
       debet   number(15,2)           -- Сумма задолженности       
       );
  type tbl_sum is table of t_sum;
  function fn_company_getdolg(pClntId clients_dic.clnt_id%type)
           return tbl_sum pipelined parallel_enable;                                                                       
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
-- Ю.К. 26.06.2017
function fn_orders_docs(
                        p_clnt_id clients_dic.clnt_id%type
                      , p_filter_string varchar2
                      , p_offset number
                      , p_limit number
                      ) 
                      return tbl_docs pipelined --parallel_enable
                      ;
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
-- Выдача данных для построения графика размещения заказов
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
                                  , total_cou     number                        -- полное количество для постраничного вывода
                                  );
type tbl_contractor_short is table of t_contractor_short;
function Contractors(
                      p_id_key      clients.clnt_id%type      default null      -- ключ поиска по ID контрагента
                    , p_id_opr      varchar2                  default '='       -- операция поиска по ID {'>' | '<' | '='}
                    , p_type_key    clients.cltp_cltp_id%type default null      -- ключ _фильтра_ (равно) по типу контрагента
                    , p_name_key    clients.client_name%type  default null      -- ключ поиска по наименованию контрагента
                    , p_name_opr    varchar2                  default 'like'    -- операция поиска по имени (like - а что м.б. еще?)
                    , p_limit       number                    default 10
                    , p_offset      number                    default 0
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
                                , total_cou   number                            -- полное количество для постраничного вывода
                                );
function DeliveryPointsGet(p_id t_loading_places.ldpl_id%type) return t_delivery_point;

-- Адрес доставки. Получение коллекции п.4.4.5 в ТЗ на разработку АПИ (операция delivery_points)
-- Ю.К. 20.04.2017
type tbl_delivery_points is table of t_delivery_point;
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
          , p_limit       number                                default 10
          , p_offset      number                                default 0
          ) return        tbl_delivery_points pipelined
          ;

-- Задолженность. Получение коллекции. п. 4.10.1 в ТЗ на разработку АПИ (операция debts)
-- Ю.К. 24.04.2017
type t_debts is record(
                        id        number                                        -- ID заказа
                      , unit      varchar2(200)                                 -- Номер контейнера
                      , sumDolg   number(15,2)                                        -- Сумма задолженности в базовой валюте
                      , date_end  date                                          -- Дата оплаты счета
                      , status    varchar2(200)                                 -- Статус заказа
                      , BaseCurrency varchar2(50)                              -- Базовая валюта
                      );
type tbl_debts is table of t_debts;
function Debts(
                p_id          number                                            -- ID клиента
              , p_limit       number                                            -- Число возвращаемых строк
              , p_start_with  number  default 1                                 -- Номер первой возвращаемой строки
              ) return tbl_debts  pipelined
              ;

-- Коллекции контрагентов. Получение коллекции. п. 4.3.1.1 в ТЗ на разработку АПИ
-- Коллекция грузоотправителей по заказам Клиента (Название операции: shippers)
type t_shippers is record(
                    id        clients.clnt_id%type,            -- ID грузоотправителя
                    client_name      clients.client_name%type,     -- Название организации
                    official_address       clients.address%type,   -- Юридический адрес
                    official_address_zip  clients.zip%type,        -- Почтовый индекс (юридический адрес)
                    actual_address   clients.address_fact%type,    -- Фактический адрес
                    actual_address_zip   clients.zip_fact%type    -- Почтовый индекс (фактический адрес)
                   
            );
            
type tbl_shippers is table of t_shippers;

function getShippers(p_id number ,
          p_clnt_id_key clients.clnt_id%type default null,
          p_client_name_key clients.client_name%type default '%',
          p_official_address_key clients.address%type default '%',
          p_official_address_zip_key clients.zip%type default '%',
          p_actual_address_key clients.address_fact%type default '%',
          p_actual_address_zip_key clients.zip_fact%type default '%',
          p_clnt_id_opr    varchar2  default '=',
          p_client_name_opr    varchar2  default 'like',
          p_official_address_opr    varchar2  default 'like',
          p_official_address_zip_opr    varchar2  default 'like',
          p_actual_address_opr    varchar2  default 'like',
          p_actual_address_zip_opr    varchar2  default 'like',
          
                     p_limit       number  default 10,                                     
                     p_start_with  number  default 0,
                     p_sort_line   varchar2  default 'clnt_id asc, client_name asc, official_address asc, actual_address asc') return tbl_shippers  pipelined;
                     
                     
-- Коллекция грузополучателей по заказам Клиентов
-- Название операции: consignees	
type t_consignees is record(
                     clnt_id        clients.clnt_id%type,          -- ID грузоотправителя
                     client_name      clients.client_name%type,    -- Название организации
                     official_address       clients.address%type,  -- Юридический адрес
                     official_address_zip  clients.zip%type,       -- Почтовый индекс (юридический адрес)
                     actual_address   clients.address_fact%type,   -- Фактический адрес
                     actual_address_zip   clients.zip_fact%type   -- Почтовый индекс (фактический адрес)
                     );
                     
type tbl_consignees is table of t_consignees;

function getConsignees(p_id number ,
          p_clnt_id_key clients.clnt_id%type default null,
          p_client_name_key clients.client_name%type default '%',
          p_official_address_key clients.address%type default '%',
          p_official_address_zip_key clients.zip%type default '%',
          p_actual_address_key clients.address_fact%type default '%',
          p_actual_address_zip_key clients.zip_fact%type default '%',
          p_clnt_id_opr    varchar2  default '=',
          p_client_name_opr    varchar2  default 'like',
          p_official_address_opr    varchar2  default 'like',
          p_official_address_zip_opr    varchar2  default 'like',
          p_actual_address_opr    varchar2  default 'like',
          p_actual_address_zip_opr    varchar2  default 'like',
          
                     p_limit       number  default 10,                                     
                     p_start_with  number  default 0,
                     p_sort_line   varchar2  default 'clnt_id asc, client_name asc, official_address asc, actual_address asc') return tbl_shippers  pipelined;
                     
-- Контактные лица контрагентов (грузоотправители и грузополучатели)
type t_persons is record(
                        id        client_contacts.clcn_id%type,     -- ID контактного лица
                       name      varchar2(4000),                   -- Полное имя контактного лица
                       phone       client_contacts.phone%type,     -- Телефон контактного лица
                       email  client_contacts.email%type,          -- Электронная почта
                       position    client_contacts.job%type,       -- Должность занимаемая контактным лицом
					             is_decide    client_contacts.lpr%type      -- Может принимать решение? 0 - нет 1 - да
                      );

type tbl_persons is table of t_persons;
function getPersons(clnt_id number) return tbl_persons  pipelined;

-- ЮК, 21.06.2017
-- Файлы-приложения к документам:
type t_files is record(
    file_id   doc_stores.dstr_id%type     -- ID файла
  , file_name doc_stores.file_name%type   -- Имя файла
  , file_size number                      -- Размер файла в байтах
);
type tbl_files is table of t_files;
function fn_doc_files(p_doc_id doc_stores.dcmt_dcmt_id%type) return tbl_files pipelined;

-- ============================================================
-- 20.10.2017 A.Starshinin
-- Возвращает дебеторскую задолженность по клиенту на заданную дату
-- ============================================================
-- Приложение: SBCFinance
-- Назначение: Возвращает дебеторскую задолженность по клиенту на заданную дату
-- Параметры:  pStartDate - дата начала периода
--             pClntId - код клиента
--             pHoldId - холдинг
--             pDate   - дата
--             pWarranty - гарантия оплаты null-все, 0-нет,1-да
-- ============================================================
function GetClientDebetDolg(pClntId in clients.clnt_id%type,
                                              pHoldId in holding.hold_id%type,
                                              pDate   date,
                                              pDolgType integer,
                                              pPlatId integer default 0,
                                              pCurId integer default 0,
                                              pWarranty invoices.pr_dept%type default null
                                              ) return number;


type t_client_debet_dolg_ex is record (
  cur_code currencies.code%type,
  amount number(15,2)
);

type tbl_client_debet_dolg_ex is table of t_client_debet_dolg_ex;

-- ================================================================================
-- Возвращает дебиторскую задолженность контрагента на текущую дату в разрезе валют
-- Автор: Игнатенко А.
-- ================================================================================
function GetClientDebetDolgEx(
   p_clnt_id in clients.clnt_id%type        -- Код контрагента
) return tbl_client_debet_dolg_ex pipelined parallel_enable;

--===================================================================================
-- Порт прибытия контейнера по заказу
-- 24.11.17  А. Старшинин
--====================================================================================
function GetPOD_ord (
        pOrdid  t_orders.ord_id%type) return ports.def%type;
        
--=======================================================================================
-- 27.11.17 А. Старшинин
-- Данные по стране, городу и порту отправления заказа
-- Выдаются из первого коносамента (накладной) по заказу
-- ======================================================================================   
function GetFirstKonosament(pOrdId in t_orders.ord_id%type) return konosaments.knsm_id%type;

--- 02.02.2018 Функция выдачи финансовой информации по заказу
function GetOrder_receivables (pOrdId in t_orders.ord_id%type,
                               pValueType in number) return number;
               
end MCSF_API;
/
create or replace package body MCSF_API is

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
    -- ins_syslog;
    for cur in (
       select o.ord_id id,                                                     -- Код заказа (id)
              lp.address_source||' '||cit_lp.def||' '||cou_lp.def place_from,  -- Адрес отправки
              dp.address_source||' '||cit_dp.def||' '||cou_dp.def place_to,    -- Адрес назначения     
              ost.def status,                                                  -- Оперативный статус
              ost.orst_id status_id,                                           -- Идентификатор статуса
              o.complete_date  date_closed,                                    -- Дата завершения заказа
              GetOrder_receivables(o.ord_id,0) receivables,                    -- Сумма задолженности по заказу
              GetOrder_receivables(o.ord_id,1) amount,                         -- Оплаченная сумма
     
              (select count(*) 
                 from MESSAGES2CUSTOMERS t
                where t.ord_ord_id = o.ord_id and
                      t.send_date is not null and
                      t.message_text not in ('NOT','message_text')
              ) notification_count,            -- Кол-во уведомлений 
              fr.def cargo_name,               -- Наименование груза
              cl_otpr_o.client_name contractor,-- Наименование грузоотправителя
              cl.ord_date created_at,          -- Дата создания заказа
              lp.source_date_plan date_from,   -- Дата отправки заказа
              dp.source_date_plan date_to,     -- Дата прибытия заказа
              case when con.cont_number is Null then 
                      null -- Номер контейнера еще не присвоен
                   else 
                      con.cont_number||' ('||ctp.def||')' 
              end te_info,                                             -- Номер и тип ТЕ
              mcsf_api.GetPOD_ord(o.ord_id) port_svh,                  -- Порт СВХ
              cou_lp.def cargo_country                                 -- Страна отправления груза              
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
  vRow_doc t_order_docs;
  vRow_unit t_unit;
  vRow_cargo t_cargo;
  vRow_messages t_message;
-- Invoices. YK, 22.07.2017:
  vRow_invcs_in_ord t_invcs_in_ord; -- счета в интересующем заказе
  --vTab_ords_in_invc tbl_ords_in_invc; -- заказы в счетах интересующего заказа
  i integer;
 begin
    for cur in (
      select o.ord_id id,-- Идентификатор заказа  
             cl_lp.client_name consignor,-- Грузоотправитель (Контрагент)        
             cl_dp.client_name consignee,-- Грузополучатель (Контрагент)        
             cl.ord_date created_at,-- Дата создания заказа      
             o.complete_date date_closed,  -- Дата завершения заказа 
             /*
             25.11.17  Информация о задолженности убрана из ТЗ
             есть новое ребование - вывод списка счетов по заказу
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
             */
            (select distinct first_value(p.def) over (order by k.knsm_date asc) 
             from konosaments k, knsm_orders ko, knor_ord ord, ports p
            where ord.ord_ord_id = o.ord_id and
                  ko.knor_id = ord.knor_knor_id and
                  k.knsm_id = ko.knsm_knsm_id and
                  p.port_id (+)= k.pol_port_id) departure_port,-- Порт отправления
            (select distinct first_value(cou.def) over (order by k.knsm_date asc) 
             from konosaments k, knsm_orders ko, knor_ord ord, cities c, countries cou
            where ord.ord_ord_id = o.ord_id and
                  ko.knor_id = ord.knor_knor_id and
                  k.knsm_id = ko.knsm_knsm_id and
                  c.city_id (+)= k.city_pol_id and
                  cou.cou_id (+)= c.cou_cou_id) departure_country,-- Страна отправления                  
             ct.def container_type,-- Тип контейнера      
             con.cont_index container_prefix,-- Префикс контейнера    
             con.cont_number container_number,-- Номер контейнера  
            (select distinct first_value(k.pol_date) over (order by k.knsm_date asc) 
             from konosaments k, knsm_orders ko, knor_ord ord
            where ord.ord_ord_id = o.ord_id and
                  ko.knor_id = ord.knor_knor_id and
                  k.knsm_id = ko.knsm_knsm_id) date_shipment,-- Дата погрузки судна         
             (select distinct first_value(k.pot_date) over (order by k.knsm_date asc) 
             from konosaments k, knsm_orders ko, knor_ord ord
            where ord.ord_ord_id = o.ord_id and
                  ko.knor_id = ord.knor_knor_id and
                  k.knsm_id = ko.knsm_knsm_id) date_transshipment,-- Дата подхода в порт перевалки
             oc.arrival_date date_arrival,-- Дата прибытия       
             nvl(vd.voch_date, ow1.voch_date) date_upload,-- Дата выгрузки       
             ow3.date_out date_export,-- Дата вывоза       
             ow3.date_plan date_submission,-- Дата сдачи порожнего    
             cit_pod.def arrival_city,-- Город прибытия      
             p_pod.def arrival_port,-- Порт прибытия       
             -- s.def arrival_ship,-- Судно (Фидер)       
             g.gtd_number gtd_number,-- ГТД номер        
             g.gtd_date gtd_date,  -- Дата ГТД    
             g.date_out gtd_issuance -- Дата выпуска ГТД                   
         from t_orders o,
             clrq_orders co, 
             client_requests cl,  
             order_ways ow1,    
             order_ways ow3,    
             t_loading_places lp,
             t_loading_places dp,
             order_cnsm_mv oc,  -- данные по стране прибытия
             vord_gtd vgt,
             gtds g,
             vVouchers vd,
             vOrder_Statuses_Last vsl,
             conteiners con,
             cities cit_pod,
             ports p_pod,  --- порт прибытия
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
          /* 
         and oc.pol_port_id      = p_pol.port_id(+)
         and oc.city_pol_id      = cit_pol.city_id(+)
         and cou_pol.cou_id      = cit_pol.cou_cou_id(+)
         */
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
       vRow.date_closed := cur.date_closed;  -- Дата закрытия заказа
     --  vRow.status := cur.status;         -- Текущий статус заказа 
       -- Сообщения менеджера  -------------------------
       vRow.messages := tbl_message();
       i := 0;
       for c1 in (select ms.mscm_id,
                         null from_mes, 
                         ms.send_to,
                         ms.message_text,
                         ms.message_date created_at,
                         null status_mes,
                         ms.ord_ord_id order_id
                    from MESSAGES2CUSTOMERS ms
                   where ms.ord_ord_id = vRow.id and
                         ms.send_date is not null and
                         ms.message_text <> 'NOT') loop 
             vRow_messages := t_message(c1.mscm_id,         --Идентификатор сообщения
                                        c1.from_mes,        -- Имя отправителя
                                        c1.send_to,         -- Адрес получателя
                                        c1.message_text,    -- Текст сообщение
                                        c1.created_at,    -- Дата создания сообщения
                                        c1.status_mes,        -- Состояние сообщения
                                        c1.order_id);       -- Идентификатор заказа
             
             i := i + 1;                            
             vRow.messages.extend;
             vRow.messages(i) :=  vRow_messages;
       end loop;      
       -- Информация о грузе ---------------------------
       vRow.cargo := tbl_cargo();
       i := 0;
       for c2 in (select f.def 
                    from freights f, order_freights ofr, loading_places lp
                   where lp.ord_ord_id = vRow.id and 
                         lp.del_user is Null and 
                         lp.ldpl_id = ofr.ldpl_ldpl_id and 
                         ofr.frgt_frgt_id = f.frgt_id) loop
               vRow_cargo := t_cargo(c2.def); 
               i := i +1 ;                      
               vRow.cargo.extend;
               vRow.cargo(i)    :=  vRow_cargo;
       end loop;
       -- Информация о ТЕ ------------------------------
       vRow.unit := tbl_unit();
       i := 0;
       for c3 in (select ct.def || ' ' || c.cont_index || c.cont_number unit_info
                    from t_orders o, conteiners c, conteiner_types ct
                   where o.ord_id = vRow.id and
                         c.cont_id (+)= o.cont_cont_id and
                         ct.cntp_id (+)= c.cntp_cntp_id ) loop
           vRow_unit := t_unit(c3.unit_info);
           i := i + 1;
           vRow.unit.extend;
           vRow.unit(i) :=  vRow_unit;
       end loop;    
       -- Прилагаемые документы ------------------------
       vRow.doc       := tbl_order_docs();
       i := 0;
       for c4 in (select d.dcmt_id id, 
                         vRow.id order_id,
                         dt.dctp_id type_id,
                         dt.def doc_type,
                         d.doc_date doc_date,
                         d.navi_date uploaded_at,
                         null owner
                    from doc_links dl, documents d, doc_types dt
                   where dl.ord_ord_id = vRow.id and
                         d.del_date is null and
                         d.dcmt_id (+) = dl.dcmt_dcmt_id and
                         dt.dctp_id (+)= d.dctp_dctp_id ) loop
          vRow_doc := t_order_docs(c4.id, -- Идентификатор
                                  c4.order_id, -- Идентификатор заказа
                                  c4.type_id,  -- Идентификатор типа документа
                                  c4.doc_type, -- Наименование документа
                                  c4.doc_date, -- Дата документа
                                  c4.uploaded_at, -- Дата загрузки
                                  c4.owner         -- Владелец документа
                                   );
          i := i +1;                         
          vRow.doc.extend;
          vRow.doc(i) := vRow_doc;
       end loop;
       -------------------------------------------------
       /*
       vRow.receivable_cost := cur.receivable_cost;
       vRow.amount_cost := cur.amount_cost;
       vRow.receivable_date := cur.receivable_date;
       vRow.receivable_status := cur.receivable_status;
       */
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
     --  vRow.arrival_ship := cur.arrival_ship;
       vRow.gtd_number := cur.gtd_number;
       vRow.gtd_date := cur.gtd_date;
       vRow.gtd_issuance := cur.gtd_issuance;
       -- Даты досмотра  -------------------------------
       vRow.rummage  := tbl_rummage();
       i := 0;
       for rd in (select ct.def type_rummage, co.chot_date date_rummage
                    from check_outs co, check_out_types ct
                   where co.ord_ord_id = cur.id and
                         ct.chtp_id = co.chtp_chtp_id)
        loop
         vRow_rummage := t_rummage(rd.type_rummage,    -- Вид досмотра
                                        rd.date_rummage -- Дата досмотра
                                        );
         i := i + 1;                               
         vRow.rummage.extend;
         vRow.rummage(i)    :=  vRow_rummage;
        end loop;
        
        -- Информация по счетам. YK, 22.07.2017 ---------
        vRow.invoices := tbl_invcs_in_ord();
        for c in (
          select rownum as rn, invc_id as id, price as total,
                (select sum(oplacheno) from invoice_details where invoice_details.invc_invc_id = inv.invc_id) as paid, 
                 pay_date as pay_to, 
                 (select def from currencies where currencies.cur_id = inv.cur_cur_id) as currency
           from invoices inv where inv.intp_intp_id = 1 and inv.invc_id in
                (select invc_invc_id from invoice_details id where ord_ord_id = pID)
        ) loop
          vRow_invcs_in_ord := t_invcs_in_ord(c.id, c.total, c.paid, c.pay_to, c.currency);
          vRow.invoices.extend;
          vRow.invoices(c.rn) := vRow_invcs_in_ord;
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
                      d.dctp_dctp_id type_id,  -- Тип документа
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

-- Ю.К. 26.06.2017
function fn_orders_docs(
                        p_clnt_id clients_dic.clnt_id%type
                      , p_filter_string varchar2
                      , p_offset number
                      , p_limit number
                      ) 
                      return tbl_docs pipelined --parallel_enable
is
  type cur_type is ref cursor;
  cur cur_type;
  v_sql varchar2(2000);
  v_min number := p_offset;
  v_max number := p_offset + p_limit;
  v_rec t_docs;
begin
  v_sql := '
              select id, order_id, type_doc, name_doc, date_doc, uploaded_at, owner
              from
              (
              select rownum rn, id, order_id, type_doc, name_doc, date_doc, uploaded_at, owner
              from
              (
               select d.dcmt_id id,
                      dl.ord_ord_id order_id,
                      d.dctp_dctp_id type_doc,
                      dt.def name_doc,
                      d.doc_date date_doc,
                      d.navi_date uploaded_at,
                      d.navi_user owner
                 from documents d, doc_links dl, doc_types dt,t_orders o, clrq_orders clrq, client_requests cl
                where 
                      d.doc_state = 0 and
                      dl.dcmt_dcmt_id = d.dcmt_id and
                      o.ord_id = dl.ord_ord_id and
                      clrq.ord_ord_id = o.ord_id and
                      cl.clrq_id = clrq.clrq_clrq_id and
                      cl.clnt_clnt_id = :p_clnt_id and
                      dt.dctp_id = d.dctp_dctp_id' || p_filter_string || '
             order by d.dcmt_id
             )
             where rownum <= :m_ax
             )
             where rn >= :m_in
  ';
   open cur for v_sql using p_clnt_id, v_max, v_min;
     loop
      fetch cur into v_rec;
      exit when cur%notfound;
      pipe row(v_rec);
     end loop;
     close cur;
     return;       
end fn_orders_docs;

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
currency_code currencies_dic.code%type;
 -- Функция подсчета количества заказов за историю компании
 function getTotalorders(pClntId in clients.clnt_id%type) return number is
 begin
   select count(cr.clrq_id) 
     into TotalOrders
     from client_requests cr
    where cr.clnt_clnt_id = pClntId and
          cr.del_date is null; 
   return TotalOrders;
 exception
   when others then
     return 0;  
 end; 
  
begin
  TotalOrders := getTotalorders(pClntId);
  for cur in (select cl.clnt_id,               --  ИД компании
                     cl.client_name,           -- Название компании
                     ' ' phone,               -- Рабочий телефон (появится в новых версиях системы)
                     tp.def tarif_plan,        -- Тарифный план                    
                     TotalOrders total_orders  -- Кол-во заказов за всю историю работы
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
  for cur in (select last_name || ' ' || first_name fio,
                     job, 
                     nvl(phone,'Данные отсутствуют') phone, 
                     nvl(mobile,'Данные отсутствуют') mobile
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
Request sample:
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
Query sample:
select clnt_id as id, client_name as name, cltp_cltp_id as type from clients
where upper(client_name) like upper('%123%')
and cltp_cltp_id = 10
and clnt_id > 100
;  
*/
function Contractors(
                      p_id_key      clients.clnt_id%type      default null      -- ключ поиска по ID контрагента
                    , p_id_opr      varchar2                  default '='       -- операция поиска по ID {'>' | '<' | '='}
                    , p_type_key    clients.cltp_cltp_id%type default null      -- ключ _фильтра_ (равно) по типу контрагента
                    , p_name_key    clients.client_name%type  default null      -- ключ поиска по наименованию контрагента
                    , p_name_opr    varchar2                  default 'like'    -- операция поиска по имени (like - а что м.б. еще?)
                    , p_limit       number                    default 10
                    , p_offset      number                    default 0
                    ) 
                    return          tbl_contractor_short      pipelined
is
  p_sort_line varchar2(100) default 'client_name';                              -- ORDER BY p_sort_line
  is_ok number := 0;                                                            -- для проверки входных параметров управления
  v_sql varchar2(20000) := 'select clnt_id as id, client_name as name, cltp_cltp_id as type, count(*) over () as total_cou from clients where 1 = 1 '; -- give-all default filter
  type t_contr is ref cursor; cur t_contr;
  v_rec t_contractor_short;
begin
  select decode(p_id_opr, '>',1, '<',1, '=',1, 0) * decode(upper(p_name_opr), 'LIKE',1, 0) into is_ok from dual;
  if is_ok != 1 then return; end if;
  if p_type_key is not null then
    v_sql := v_sql || ' and cltp_cltp_id = ' || p_type_key;
  end if;
  if p_id_key is not null then
    v_sql := v_sql || ' and clnt_id ' || p_id_opr || ' ' || p_id_key;
  end if;
  if p_name_key is not null then
    v_sql := v_sql || ' and upper(client_name) ' || p_name_opr || ' upper(''' || p_name_key || ''')';
  end if;
  if p_sort_line is not null then
    v_sql := v_sql || ' order by ' || p_sort_line;
    v_sql := 'select id, name, type, total_cou from (select rownum as rn, c.* from (' || v_sql || ') c where rownum <= ' || to_char(p_offset + p_limit) || ') where rn > ' || to_char(p_offset);
  end if;
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
    , count(*) over () as total_cou
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
          , p_limit       number                                default 10
          , p_offset      number                                default 0          
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
, count(*) over () as total_cou
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
  if p_id_key is not null then
    v_sql := v_sql 
      || ' and lp.ldpl_id ' || p_id_opr || ' ' || p_id_key;
  end if;
  v_sql := v_sql     
    || ' and nvl(upper(ct.name), '' '') ' || p_name_opr || ' upper(''' || p_name_key || ''')'
    || ' and nvl(upper(lp.address_source), '' '') ' || p_addr_opr || ' upper(''' || p_addr_key || ''')'
    || ' and nvl(upper(ct.phone), '' '') ' || p_phone_opr || ' upper(''' || p_phone_key || ''')'
    || ' and nvl(upper(ct.email), '' '') ' || p_email_opr || ' upper(''' || p_email_key || ''')'
    ;
  if p_sort_line is not null then
    v_sql := v_sql || ' order by ' || p_sort_line;
    v_sql := 'select id, address, phone, email, name, total_cou from (select rownum as rn, c.* from ('|| v_sql ||') c where rownum <= ' || to_char(p_offset + p_limit) || ') where rn > ' || to_char(p_offset);
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
    select id, unit, sumDolg, date_end, status,
           (select ap.value_string from app_parameters ap where ap.prmt_id = 2) BaseCurrency
      from (select rownum rnum, id, unit, sumDolg, date_end, status
             from 
                (
                 select o.ord_id as id,
                        c.cont_index || ' ' || c.cont_number as unit, 
                        sum(round((id.quantity * id.price - id.oplacheno)/id.base_rate_det, 2)) as sumDolg, 
                        i.pay_date as date_end, 
                        os.def as status
                   from client_requests r, clrq_orders ro, t_orders o, 
                        conteiners c, invoice_details id, invoices i, vorder_statuses_last sl, order_statuses os
                  where ro.clrq_clrq_id = r.clrq_id
                        and o.ord_id = ro.ord_ord_id
                        and o.del_date is null
                        and c.cont_id = o.cont_cont_id
                        and id.ord_ord_id = o.ord_id
                        and i.invc_id = id.invc_invc_id
                        and i.intp_intp_id = 1 
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


                   
 
-- Коллекции контрагентов. Получение коллекции. п. 4.3.1.1 в ТЗ на разработку АПИ
--  Массив контактных лиц контрагента     
                
function getPersons(clnt_id number) return tbl_persons  pipelined
is
 
begin
  for cur in (
            select c.clcn_id as id,
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
        

        
function getConsignees(p_id number ,
          p_clnt_id_key clients.clnt_id%type default null,
          p_client_name_key clients.client_name%type default '%',
          p_official_address_key clients.address%type default '%',
          p_official_address_zip_key clients.zip%type default '%',
          p_actual_address_key clients.address_fact%type default '%',
          p_actual_address_zip_key clients.zip_fact%type default '%',
          p_clnt_id_opr    varchar2  default '=',
          p_client_name_opr    varchar2  default 'like',
          p_official_address_opr    varchar2  default 'like',
          p_official_address_zip_opr    varchar2  default 'like',
          p_actual_address_opr    varchar2  default 'like',
          p_actual_address_zip_opr    varchar2  default 'like',
          
                     p_limit       number  default 10,                                     
                     p_start_with  number  default 0,
                     p_sort_line   varchar2  default 'clnt_id asc, client_name asc, official_address asc, actual_address asc') return tbl_shippers  pipelined
is

  is_ok number := 0;
  v_sql varchar2(20000) := 'select distinct c.clnt_id as id, 
      c.client_name,   
      c.address as official_address,
      c.zip as official_address_zip,
      c.address_fact as actual_address,
      c.zip_fact as actual_address_zip
  from clients c, t_loading_places tlp, client_requests cr
  where tlp.source_clnt_id = c.clnt_id and 
        ldpl_type = 1 and 
        cr.clrq_id = tlp.clrq_clrq_id and 
        cr.clnt_clnt_id = ' || p_id ||' ';
  type t_lp is ref cursor; cur t_lp;
  v_rec t_shippers;                 
  
 
  
begin
   select 
      decode(p_clnt_id_opr, '>',1, '<',1, '=',1, '>=',1, '<=',1, 0) 
    * decode(upper(p_client_name_opr), 'LIKE',1, 0) 
    * decode(upper(p_official_address_opr), 'LIKE',1, 0) 
    * decode(upper(p_official_address_zip_opr), 'LIKE',1, 0) 
    * decode(upper(p_actual_address_opr), 'LIKE',1, 0) 
  * decode(upper(p_actual_address_zip_opr), 'LIKE',1, 0) 
    into is_ok from dual;
  if is_ok != 1 then return; end if;
  if p_clnt_id_key is not null then
    v_sql := v_sql || ' and c.clnt_id ' || p_clnt_id_opr || ' ' || p_clnt_id_key;
  end if;
 
  v_sql := v_sql     
    || ' and nvl(upper(c.client_name), '' '') ' || p_client_name_opr || ' upper(''%' || p_client_name_key || '%'')'
    || ' and nvl(upper(c.address), '' '') ' || p_official_address_opr || ' upper(''%' || p_official_address_key || '%'')'
    || ' and nvl(upper(c.zip), '' '') ' || p_official_address_zip_opr || ' upper(''%' || p_official_address_zip_key || '%'')'
    || ' and nvl(upper(c.address_fact), '' '') ' || p_actual_address_opr || ' upper(''%' || p_actual_address_key || '%'')'
  || ' and nvl(upper(c.zip_fact), '' '') ' || p_actual_address_zip_opr || ' upper(''%' || p_actual_address_zip_key || '%'')'
    ;
  if p_sort_line is not null then
    v_sql := v_sql || ' order by ' || p_sort_line;
    v_sql := 'select id,client_name,official_address,official_address_zip,actual_address,actual_address_zip from (select rownum as rn, c.* from ('|| v_sql ||') c where rownum <= ' || to_char(p_start_with + p_limit) || ') where rn > ' || to_char(p_start_with);
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
end getConsignees;

        
function getShippers(p_id number ,
          p_clnt_id_key clients.clnt_id%type default null,
          p_client_name_key clients.client_name%type default '%',
          p_official_address_key clients.address%type default '%',
          p_official_address_zip_key clients.zip%type default '%',
          p_actual_address_key clients.address_fact%type default '%',
          p_actual_address_zip_key clients.zip_fact%type default '%',
          p_clnt_id_opr    varchar2  default '=',
          p_client_name_opr    varchar2  default 'like',
          p_official_address_opr    varchar2  default 'like',
          p_official_address_zip_opr    varchar2  default 'like',
          p_actual_address_opr    varchar2  default 'like',
          p_actual_address_zip_opr    varchar2  default 'like',
          
                     p_limit       number  default 10,                                     
                     p_start_with  number  default 0,
                     p_sort_line   varchar2  default 'clnt_id asc, client_name asc, official_address asc, actual_address asc') return tbl_shippers  pipelined
is

  is_ok number := 0;
  v_sql varchar2(20000) := 'select distinct c.clnt_id as id, 
      c.client_name,   
      c.address as official_address,
      c.zip as official_address_zip,
      c.address_fact as actual_address,
      c.zip_fact as actual_address_zip
  from clients c, t_loading_places tlp, client_requests cr
  where tlp.source_clnt_id = c.clnt_id and 
        ldpl_type = 0 and 
        cr.clrq_id = tlp.clrq_clrq_id and 
        cr.clnt_clnt_id = ' || p_id ||' ';
  type t_lp is ref cursor; cur t_lp;
  v_rec t_shippers;                 
  
 
  
begin
   select 
      decode(p_clnt_id_opr, '>',1, '<',1, '=',1, '>=',1, '<=',1, 0) 
    * decode(upper(p_client_name_opr), 'LIKE',1, 0) 
    * decode(upper(p_official_address_opr), 'LIKE',1, 0) 
    * decode(upper(p_official_address_zip_opr), 'LIKE',1, 0) 
    * decode(upper(p_actual_address_opr), 'LIKE',1, 0) 
  * decode(upper(p_actual_address_zip_opr), 'LIKE',1, 0) 
    into is_ok from dual;
  if is_ok != 1 then return; end if;
  if p_clnt_id_key is not null then
    v_sql := v_sql || ' and c.clnt_id ' || p_clnt_id_opr || ' ' || p_clnt_id_key;
  end if;
 
  v_sql := v_sql     
    || ' and nvl(upper(c.client_name), '' '') ' || p_client_name_opr || ' upper(''%' || p_client_name_key || '%'')'
    || ' and nvl(upper(c.address), '' '') ' || p_official_address_opr || ' upper(''%' || p_official_address_key || '%'')'
    || ' and nvl(upper(c.zip), '' '') ' || p_official_address_zip_opr || ' upper(''%' || p_official_address_zip_key || '%'')'
    || ' and nvl(upper(c.address_fact), '' '') ' || p_actual_address_opr || ' upper(''%' || p_actual_address_key || '%'')'
  || ' and nvl(upper(c.zip_fact), '' '') ' || p_actual_address_zip_opr || ' upper(''%' || p_actual_address_zip_key || '%'')'
    ;
  if p_sort_line is not null then
    v_sql := v_sql || ' order by ' || p_sort_line;
    v_sql := 'select id,client_name,official_address,official_address_zip,actual_address,actual_address_zip from (select rownum as rn, c.* from ('|| v_sql ||') c where rownum <= ' || to_char(p_start_with + p_limit) || ') where rn > ' || to_char(p_start_with);
  end if;
  

dbms_output.Put_line(v_sql); 
  open cur for v_sql;
  loop
 
    fetch cur into v_rec;
  
    exit when cur%notfound;
    pipe row(v_rec);
  end loop;
  close cur;
  return;
exception when no_data_found then return;
end getShippers;



function fn_doc_files(p_doc_id doc_stores.dcmt_dcmt_id%type) return tbl_files pipelined
is
begin
  for cur in (
    select dstr_id as file_id, file_name, dbms_lob.getlength(doc_data) as file_size
    from doc_stores where dcmt_dcmt_id = p_doc_id
    order by dstr_id
  ) loop
    pipe row(cur);
  end loop;
  return;
end fn_doc_files;

-- ============================================================
-- Возвращает дебеторскую задолженность по клиенту на заданную дату
-- ============================================================
-- Приложение: SBCFinance
-- Назначение: Возвращает дебеторскую задолженность по клиенту на заданную дату
-- Параметры:  pStartDate - дата начала периода
--             pClntId - код клиента
--             pHoldId - холдинг
--             pDate   - дата
-- ============================================================
function GetClientDebetDolg(pClntId in clients.clnt_id%type,
                                              pHoldId in holding.hold_id%type,
                                              pDate   date,
                                              pDolgType integer,
                                              pPlatId integer default 0,
                                              pCurId integer default 0,
                                              pWarranty invoices.pr_dept%type default null
                                              ) return number as
  Result number;
begin
  select (sum(debet_base_amount) - sum(debet_base_oplacheno))
    into Result
    from -- считаем дебиторскую задолженность по счетам
         (select hold_hold_id,
                 cur_cur_id,
                 sum(round(nvl(debet_amount, 0) / nvl(decode(pCurId, 0, base_rate, 1), 1), 2)) debet_base_amount,
                 sum(nvl(debet_oplacheno, 0) / nvl(decode(pCurId, 0, base_rate, 1), 1)) debet_base_oplacheno
            from (select i.invc_id,
                         i.hold_hold_id,
                         i.cur_cur_id,
                         i.clnt_clnt_id,
                         i.price - nvl((select sum(cp.summa_oper)
                                          from cash_prixods cp, kredit_notes kn
                                         where cp.invc_invc_id = i.invc_id
                                           and cp.krnt_krnt_id = kn.krnt_id
                                           and kn.kredit_date <= trunc(pDate)
                         ),0) debet_amount,
                         inv_date,
                         (select sum(cp.summa_oper)
                            from cash_prixods cp,
                                 prix_orders  po,
                                 bndc_details bdt,
                                 bank_docs    bd,
                                 cash_rasxods cr,
                                 invoices     i2
                           where cp.invc_invc_id = i.invc_id
                             and cp.pror_pror_id = po.pror_id(+)
                             and cp.bddt_bddt_id = bdt.bddt_id(+)
                             and bdt.bndc_bndc_id = bd.bndc_id(+)
                             and cp.chrs_chrs_id = cr.chrs_id(+)
                             and cr.invc_invc_id = i2.invc_id(+)
                             and cp.krnt_krnt_id is null
                             and nvl(bd.bndc_date,
                                     nvl(po.date_order,
                                         nvl(i2.inv_date, i.inv_date))) <=
                                 trunc(pDate)) debet_oplacheno,
                         i.base_rate
                    from invoices i
                   where i.del_date is null
                     and i.intp_intp_id = 1
                     and decode(pDolgType,0,i.inv_date,1,i.pay_date,null) <= trunc(pDate)
                     and nvl(i.complete_date,
                             to_date('01.12.2999', 'dd.mm.yyyy')) >
                         trunc(pDate)
                     and i.hold_hold_id = pHoldId
                     and ((to_char(pCurId) = '0') or (cur_cur_id = pCurId))
                     and ((i.CLIENT_PLAT_ID =  pPlatId) or (nvl(pPlatId,0) = 0))
                     and nvl(pWarranty, i.pr_dept) = i.pr_dept
                     and clnt_clnt_id = pClntId)
           group by hold_hold_id, cur_cur_id);

  return(nvl(Result, 0));
exception
  when others then return(null);
end GetClientDebetDolg;
 
-- Возвращает дебеторскую задолженность контрагента на текущую дату в разрезе валют
function GetClientDebetDolgEx(
   p_clnt_id in clients.clnt_id%type        -- Код контрагента
) return tbl_client_debet_dolg_ex pipelined parallel_enable
is
begin
  for l_cur in (
     select cur.code,
            sum(i.price - nvl((select sum(cp.summa_oper)
                            from cash_prixods cp, kredit_notes kn
                           where cp.invc_invc_id = i.invc_id
                             and cp.krnt_krnt_id = kn.krnt_id
                             and kn.kredit_date <= trunc(sysdate)
             ),0)) -
             nvl(sum((select sum(cp.summa_oper)
                from cash_prixods cp,
                     prix_orders  po,
                     bndc_details bdt,
                     bank_docs    bd,
                     cash_rasxods cr,
                     invoices     i2
               where cp.invc_invc_id = i.invc_id
                 and cp.pror_pror_id = po.pror_id(+)
                 and cp.bddt_bddt_id = bdt.bddt_id(+)
                 and bdt.bndc_bndc_id = bd.bndc_id(+)
                 and cp.chrs_chrs_id = cr.chrs_id(+)
                 and cr.invc_invc_id = i2.invc_id(+)
                 and cp.krnt_krnt_id is null
                 and nvl(bd.bndc_date,
                         nvl(po.date_order,
                             nvl(i2.inv_date, i.inv_date))) <= trunc(sysdate))),0)
      from invoices i,
           currencies cur
     where i.del_date is null
       and i.intp_intp_id = 1
       and i.inv_date <= trunc(sysdate)
       and nvl(i.complete_date, to_date('01.12.2999', 'dd.mm.yyyy')) >  trunc(sysdate)
       and clnt_clnt_id = p_clnt_id
       and cur.cur_id = i.cur_cur_id
      group by cur.code
      order by 1
  )  
  loop  
    pipe row (l_cur);
  end loop;
  return;
end;

-- Функция выдачи данных о дебиторской задолженности в по валютам счетов
function fn_company_getdolg(pClntId clients_dic.clnt_id%type)
           return tbl_sum pipelined parallel_enable is                      
begin
  for l_cur in (
     select t.cur_code currency, 
            t.amount debet
       from table(mcsf_api.GetClientDebetDolgEx(p_clnt_id => pClntId)) t
     )
  loop
    pipe row (l_cur);
  end loop;
  return; 
end;

--===================================================================================
-- Порт прибытия контейнера по заказу
-- 24.11.17  А. Старшинин
--====================================================================================
function GetPOD_ord (
        pOrdid  t_orders.ord_id%type) return ports.def%type is
vPOD ports.def%type;        
begin
  select p.def pod
    into vPOD
    from konosaments k, ports p, knor_ord ko, knsm_orders knsm
   where ko.ord_ord_id = pOrdId and
         knsm.knor_id (+)= ko.knor_knor_id and
         k.knsm_id (+)= knsm.knsm_knsm_id and
         p.port_id (+)= k.pod_port_id and
         k.is_custom = 1;
    return vPOD;
exception
   when no_data_found then
       return 'Нет информации';
   when others then
       return '';        
end;        

--=======================================================================================
-- 27.11.17 А. Старшинин
-- Данные по стране, городу и порту отправления заказа
-- Выдаются из первого коносамента (накладной) по заказу
-- ======================================================================================   
function GetFirstKonosament(pOrdId in t_orders.ord_id%type) return konosaments.knsm_id%type is
KnsmDate konosaments.knsm_date%type;  
KnsmId   konosaments.knsm_id%type;
begin
   select k.knsm_id, min(k.knsm_date)
     into Knsmid, KnsmDate
     from konosaments k, knsm_orders ko, knor_ord kord
    where kord.ord_ord_id = pOrdId and
          ko.knor_id = kord.knor_knor_id and
          k.knsm_id = ko.knsm_knsm_id
   group by k.knsm_id;
   return KnsmId;
exception
  when no_data_found then
     -- Нет коносамента (накладной) по заказу в базе данных          
    return null; 
end;  

--- 02.02.2018 Функция выдачи финансовой информации по заказу
function GetOrder_receivables (pOrdId in t_orders.ord_id%type,
                               pValueType in number) return number is
receivables number(15,2);  
vSummaOrder number(15,2);
vSummaOplacheno number(15,2);
begin 
     -- сумма поступивших платежей по заказу       
     select nvl(sum(round(cp.summa_oper/i.base_rate, 2)),0)
       into vSummaOplacheno
       from invoice_details id, invoices i, cash_prixods cp
      where id.ord_ord_id   = pOrdId and 
            id.invc_invc_id = i.invc_id and 
            i.intp_intp_id  = 1 and 
            i.del_user is Null and 
            cp.indt_indt_id = id.indt_id and 
            cp.krnt_krnt_id is Null;
  if pValueType = 0 then
     -- Расчет задолженности по заказу
     -- сумма к оплате по заказу
     select nvl(sum(round(id.price*id.quantity/i.base_rate, 2)),0)
       into vSummaOrder
       from invoice_details id,invoices i 
      where id.ord_ord_id   = pOrdId and 
            id.invc_invc_id = i.invc_id and 
            i.intp_intp_id  = 1 and 
            i.del_user is Null;
     receivables := vSummaOrder - vSummaOplacheno;
  else
    -- выдача информации по сумме поступивших платежей по заказу  
     receivables := vSummaOplacheno;     
  end if;          
  return  receivables;
end;
                                   
end MCSF_API;

 
/
