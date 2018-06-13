create or replace package MCSF_API is
  
  -- ����� �������� �������� ��� ���������� ��������-������� ����
  
  PkgDefaultDateFormat varchar2(255) := 'YYYY-MM-DD HH24:MI:SS'; -- ������ ���� ��� ������������ � ������ � �������
  
  /* 
  ��� ���������: t_doc � t_docs
  */ 
  type t_doc is record(
    id documents.dcmt_id%type,            -- ������������� ���������
    order_id doc_links.ord_ord_id%type,   -- ������������� ������
    type_id doc_types_dic.dctp_id%type,   -- ������������� ���� ���������
    doc_type doc_types.def%type,          -- ������������ ���� ���������
    doc_date documents.doc_date%type,     -- ���� ���������
    uploaded_at documents.navi_date%type, -- ���� ��������
    owner documents.navi_user%type        -- �������� ���������
 );
 
 type tbl_docs is table of t_doc; 


-- ������ ������ ������� (orders)
--*********************************************************************************************************************
  type t_order_record is record (
   id                    t_orders.ord_id%type,                   -- ��� ������ (id)
   place_from            t_loading_places.address_source%type,   -- ����� ��������
   place_country_from    t_loading_places.address_source%type,   -- ������ ��������
   place_city_from       t_loading_places.address_source%type,   -- ����� ��������
   place_to              t_loading_places.address_source%type,   -- ����� ����������
   place_country_to      t_loading_places.address_source%type,   -- ������ ����������
   place_city_to         t_loading_places.address_source%type,   -- ����� ����������
   status              order_statuses.def%type,                -- ����������� ������ ������
   status_id           order_statuses.orst_id%type,            -- ������������� �������
   date_closed         t_orders.complete_date%type,            --  ���� ���������� ������. ������������ ����� string
   receivables         number(15,2),                           -- ����� ������������� �� ������
   amount              number(15,2),                           -- ���������� �����
   notification_count  number(15,2),                           -- ���-�� ����������� 
   cargo_name          freights.def%type,                      -- ������������ �����
   created_at          client_requests.ord_date%type,          -- ���� �������� ������
   date_from           t_loading_places.source_date_plan%type, -- ���� �������� ������
   date_to             t_loading_places.source_date_plan%type, -- ���� �������� ������
   te_type             varchar2(500),                          -- ����� � ��� ��
   port_svh            ports.def%type,                         -- ���� ���
   departure_country       countries.def%type,                 -- ������ ������������� �����
   shipment_date       konosaments.pol_date%type,              -- ���� �������� �����
   unload_transhipment_plan_date       konosaments.pol_date%type,             -- ���� ������� � ���� ���������
   unload_destination_plan_date       order_cnsm_mv.arrival_date%type,             -- ���� ������� � ����/��� ����������
   unload_destination_fact_date       vVouchers.voch_date%type,             -- ���� �������� � �����/��� ���������� (����)
   date_dt                            gtds.gtd_date%type, -- ���� ������ ��
   date_release_dt                    gtds.date_out%type,  -- ���� ������� ��
   dt_number                          gtds.gtd_number%type, -- ����� ��
   date_export_port                          order_ways.date_out%type, -- ���� ������ �� �����
   date_return_empty                         order_ways.date_plan%type, -- ���� �������� ���������
   customer_delivery_date                    order_ways.date_plan%type, -- ���� �������� �� ����� - �������, ��� ��� ���� �������� � ������� ( � �������� "���� �������� � ����� ����������")
   am_number                                 cars.state_number%type, -- ����� ��
   fio_driver                                cmrs.driver_name%type, -- ��� ��������
   "consignor.id"                            clients.clnt_id%type,
   "consignor.name"                          clients.client_name%type,             -- ���������������� (����������)
   "consignee.id"                            clients.clnt_id%type,
   "consignee.name"                          clients.client_name%type             -- ��������������� (����������)
  );
  type tbl_orders is table of t_order_record;

 function GetOrders(pClntId client_requests.clnt_clnt_id%type, -- ID �������
                     pFilter varchar2 default null,
                     pQueryFilter varchar2 default null,
                     pSortFilter varchar2 default null
                     ) 
   return tbl_orders pipelined parallel_enable;
             
--*********************************************************************************************************************


-- ��������� ���������� �� ������ (orders_get) �� 4.7.2
--*********************************************************************************************************************
/*
-- Invoices. YK, 22.07.2014:
type t_ords_in_invc is record (id t_orders.ord_id%type);
type tbl_ords_in_invc is table of t_ords_in_invc; -- ������ ��������������� �������, ���������� � ���� ������

type t_invcs_in_ord is record (
    id        invoices.invc_id%type
  , total     invoices.price%type
  , paid      invoice_details.oplacheno%type
  , pay_to    date
  , currency  currencies.def%type
  --, orders    tbl_ords_in_invc
  );
type tbl_invcs_in_ord is table of t_invcs_in_ord; -- ������ ������ �� ������
-- YK.
*/

 type t_order_extended_record is record (
   id                  t_orders.ord_id%type,                 -- ������������� ������
   consignor           t_mcsf_api_contractor_short,             -- ���������������� (����������)
   consignee           t_mcsf_api_contractor_short,             -- ��������������� (����������)
   created_at          client_requests.ord_date%type,        -- ���� �������� ������
   date_closed         t_orders.complete_date%type,          -- ���� ���������� ������
   -- status              order_statuses.def%type,              -- C����� ������
   messages            tbl_message,                          -- ��������� ��������� 
   cargo               tbl_cargo,                            -- ���������� � ����� 
   unit                t_mcsf_api_unit,                       -- ���������� � ��
   doc                 tbl_mcsf_api_order_docs,              -- ����������� ��������� 
   -- receivable_cost     invoices.price%type,               -- ����� �������������
   -- amount_cost         invoices.price%type,               -- ���������� �����
   -- receivable_date     invoices.pay_date%type,            -- ���� ���������
   -- receivable_status   varchar2(500),                     -- ������ �������������
   departure_port      ports.def%type,                       -- ���� �����������
   departure_country   countries.def%type,                   -- ������ �����������   
   container_type      conteiner_types.def%type,             -- ��� ����������  
   container_prefix    conteiners.cont_index%type,           -- ������� ����������  
   container_number    conteiners.cont_number%type,          -- ����� ����������
   date_shipment       t_loading_places.source_date_plan%type,-- ���� �������� �����    
   date_transshipment  konosaments.pot_date%type,            -- ���� ������� � ���� ���������
   date_arrival        transport_time_table.arrival_date%type,-- ���� �������� 
   date_upload         vouchers.voch_date%type,              -- ���� ��������
   date_export         cmrs.date_out%type,                   -- ���� ������
   customer_delivery_date         cmrs.date_in%type,         -- ���� �������� �������
   date_submission     order_ways.date_plan%type,            -- ���� ����� ��������� 
   arrival_city        cities.def%type,                      -- ����� ��������
   arrival_port        ports.def%type,                       -- ���� �������� 
 --  arrival_ship        ships.def%type,                     -- ����� (�����) 
   gtd_number          gtds.gtd_number%type,                 -- ��� �����
   gtd_date            gtds.gtd_date%type,                   -- ���� ���    
   gtd_issuance        gtds.date_out%type,                   -- ���� ������� ���
  -- data_logisticians   varchar2(1000),                     -- ������ � ��������
   rummages_count      number(10),                           -- ���������� ���������� ���������   
   rummages            tbl_mcsf_api_rummages,                -- ���� � ���� �������� 
   invoices            tbl_mcsf_api_invoices,                -- ������ ������ �� ������
   delivery_car        t_mcsf_api_delivery_car               -- ���������� �� ���������� �������� � ��������
 );
  type tbl_orders_extended is table of t_order_extended_record;
  
  -- ������� ������ ������ �� ������
  function GetOrderById(pID t_orders.ord_id%type, pClntId clients_dic.clnt_id%type) return tbl_orders_extended pipelined parallel_enable;  

--*********************************************************************************************************************


-- ������ ������ ���������� (orders_docs) �� 4.8.5
--*********************************************************************************************************************
 function GetDocuments(pClntId client_requests.clnt_clnt_id%type, -- ID �������
                     pFilter varchar2 default null,
                     pQueryFilter varchar2 default null,
                     pSortFilter varchar2 default null
                     ) 
   return tbl_mcsf_api_order_docs pipelined parallel_enable;
   
--*********************************************************************************************************************


-- ������ ������ ���������� (orders_docs) �� 4.8.1
--*********************************************************************************************************************
function GetDocument(pClntId clients_dic.clnt_id%type,
                     pId documents.dcmt_id%type) return t_mcsf_api_order_doc;
                     
--*********************************************************************************************************************


-- �������� ��������� (orders_doc_create) �� 4.8.1
--*********************************************************************************************************************
function CreateDocument(pOrdId t_orders.ord_id%type,   -- �������������� ��������� ������
                        pClntId clients_dic.clnt_id%type, -- �������������� ��������� �������
                        pDctpId doc_types_dic.dctp_id%type, -- ��� ���������
                        pDocnumber documents.doc_number%type default null, -- ����� ���������
                        pDocDate documents.doc_date%type default sysdate, -- ���� ���������
                        pTheme documents.theme%type default null,  -- ���� ���������
                        pShortContent documents.shrt_content%type default null, -- ������� �������� ��������� (����������) 
                        pAuthor documents.author%type default null -- ����� ���������
                        ) return number;
                        
--*********************************************************************************************************************


-- ���������� ��������� (orders_doc_create) �� 4.8.2
--*********************************************************************************************************************
function UpdateDocument(pClntId clients_dic.clnt_id%type,     -- �������������� ��������� �������, 
                        pDocId documents.dcmt_id%type,        -- ������������� ���������
                        pDctpId doc_types_dic.dctp_id%type, -- ��� ���������
                        pDocnumber documents.doc_number%type default null, -- ����� ���������
                        pDocDate documents.doc_date%type default sysdate, -- ���� ���������
                        pTheme documents.theme%type default null,  -- ���� ���������
                        pShortContent documents.shrt_content%type default null, -- ������� �������� ��������� (����������) 
                        pAuthor documents.author%type default null -- ����� ���������
                        ) return boolean;
                        
--*********************************************************************************************************************


-- �������� ��������� (orders_doc_delete) �� 4.8.4
--*********************************************************************************************************************                       
function RemoveDocument(pClntId clients_dic.clnt_id%type,  -- �������������� ��������� �������
                        pDocId documents.dcmt_id%type      -- ������������� ���������
                        ) return boolean;
                        
--*********************************************************************************************************************


-- ���������� ����� � �������� �� ������ (orders_doc_add_file) �� 4.8.6
--*********************************************************************************************************************  
function AddFileToDocument (pClntId clients_dic.clnt_id%type, -- �������������� ��������� �������    
                            pDocId documents.dcmt_id%type,    -- ������������� ���������
                            pFileBody doc_stores.doc_data%type, -- ���������� ����� ��� ��������
                            pFileName doc_stores.file_name%type      -- ��� �����
                            ) return integer;
                                 
--********************************************************************************************************************* 


-- ��������� ����� � �������� �� ������ (orders_doc_getfile) �� 4.8.7
--********************************************************************************************************************* 
procedure GetFile(pClntId in clients_dic.clnt_id%type,    -- �������������� ��������� �������
                  pFileId in doc_stores.dstr_id%type,     -- ������������� ������������ �����
                  pFileBody out doc_stores.doc_data%type, -- ���������� ������������ �����
                  pFileName out doc_stores.file_name%type  -- ��� �����
                  ) ;
                  
--*********************************************************************************************************************

-- ����������� �� 4.15
--*********************************************************************************************************************                  
type t_countries is record(
      id countries.cou_id%type,    -- �� ������
      def countries.def%type           -- ������
);

type tbl_countries is table of t_countries;

type t_regions is record(
      id continents.cntn_id%type,                     -- �� ����������
      region_name continents.region_name%type         -- �������� (������)
);

type tbl_regions is table of t_regions;

type t_cities is record(
      id cities.city_id%type,     -- �� ������
      def cities.def%type         -- �����
);

type tbl_cities is table of t_cities;

type t_doc_types is record(
      id doc_types_dic.dctp_id%type,   -- ������������� ���� ���������
      def doc_types.def%type           -- ��� ���������
);

type tbl_doc_types is table of t_doc_types;

type t_status is record(
      id order_statuses_dic.orst_id%type,   -- �������
      name order_statuses_dic.def%type           -- ������������ �������
);

type tbl_statuses is table of t_status;

-- ������� �������� ����������� �����
function �ountriesDic return tbl_countries pipelined parallel_enable;

-- ������� �������� ����������� ��������
function RegionsDic return tbl_regions pipelined parallel_enable;

-- ������� �������� ����������� �������
function CitiesDic return tbl_cities pipelined parallel_enable;

-- ������� �������� ������ ����������� ����� ����������
function DocTypesDic return tbl_doc_types pipelined parallel_enable;

-- ������� �������� ����������� ������
function StatusesDic return tbl_statuses pipelined parallel_enable;

--*********************************************************************************************************************

-- ������� ������ ������ �� �������� �� 4.2.1
--********************************************************************************************************************* 

-- ������ � ��������
type t_company is record(
     id clients_dic.clnt_id%type,      -- �� ��������
     client_name clients_dic.client_name%type, -- ������������ ��������
     phone  varchar2(100),             -- ������� ������� ��������
     plan tarif_plans.def%type,        -- �������� ���� ��������
     total_orders number               -- ���������� ������� �� ������� ������ ��������
     );
       
type tbl_companies is table of t_company; 
                          
function GetCompanies(pClntId clients_dic.clnt_id%type) return tbl_companies pipelined parallel_enable;

--*********************************************************************************************************************

-- ������� ������ ������ �� �������� �� 4.2.1
--*********************************************************************************************************************
type t_company_contacts is record(
     fio varchar2(4000),   -- ��� ����������� ����
     job client_contacts.job%type, -- ���������
     phone client_contacts.phone%type, -- ����� �������� ��������
     mobile client_contacts.mobile%type -- ����� ���������� ��������
     );
type tbl_company_contacts is table of t_company_contacts;             
  
function GetCompanyContacts(pClntId clients_dic.clnt_id%type) return tbl_company_contacts pipelined parallel_enable;

--*********************************************************************************************************************                     

-- ������� ������ ������ � ����������� ������������� � �� ������� ������ �� 4.2.1
--*********************************************************************************************************************                           

type t_sum is record(
     currency currencies.code%type, -- ������ �������������
     debet   number(15,2)           -- ����� �������������       
     );
     
type tbl_sum is table of t_sum;

function GetCompanyDolg(pClntId clients_dic.clnt_id%type) return tbl_sum pipelined parallel_enable;
                                                                       
--*********************************************************************************************************************

-----------------------------------------------------------------------------
--- ������ � �����������
--- ������ ���������  
function fn_orders_doc_depricated(pID documents.dcmt_id%type,
                       pClntId clients_dic.clnt_id%type) return tbl_docs pipelined parallel_enable; 
-- �.�. 26.06.2017
function fn_orders_docs_depricated(
                        p_clnt_id clients_dic.clnt_id%type
                      , p_filter_string varchar2
                      , p_offset number
                      , p_limit number
                      ) 
                      return tbl_docs pipelined --parallel_enable
                      ;



--*********************************************************************************************************************
-- ������ ������ ��� ���������� ������� ���������� �������
type t_da3num is record(              -- ��� ��������: �������� - ����, 3 ������� �� ���� - �����:
                          d   date
                        , n1  number
                        , n2  number
                        , n3  number
                        );
type tbl_da3num is table of t_da3num;                        
function ReportOrder( pClntId clients_dic.clnt_id%type  -- ID �������
                    , pQuant  varchar2                  -- ����� ����������� ����������� {'year'|'month'|'week'|'day'}
                    , pStart  date                      -- ������ ��������� �������
                    , pStop   date                      -- ����� ��������� �������
                    ) return tbl_da3num                 -- ���� � ��� �����
                    pipelined;
--*********************************************************************************************************************
  -- ���������� � ������������ (contractor)
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
function ContractorsGet(  pClntId       clients.clnt_id%type                    -- ID �������
                        , pAddressType  number    default null                  -- ��������, ������� � �.�. �� ������������.
                        , pPersonFor    varchar2  default null                  -- �� ��� ��������. �� ������������.
                        ) return        t_contractor;                          


-- ��������� ������������ �.4.3.2 � �� �� ���������� ��� (�������� contractors)
-- �.�. 17.04.2017
type t_contractor_short is record(
                                    id            number
                                  , name          clients.client_name%type 
                                  , type          clients.cltp_cltp_id%type
                                  , total_cou     number                        -- ������ ���������� ��� ������������� ������
                                  );
type tbl_contractor_short is table of t_contractor_short;
function Contractors(
                      p_id_key      clients.clnt_id%type      default null      -- ���� ������ �� ID �����������
                    , p_id_opr      varchar2                  default '='       -- �������� ������ �� ID {'>' | '<' | '='}
                    , p_type_key    clients.cltp_cltp_id%type default null      -- ���� _�������_ (�����) �� ���� �����������
                    , p_name_key    clients.client_name%type  default null      -- ���� ������ �� ������������ �����������
                    , p_name_opr    varchar2                  default 'like'    -- �������� ������ �� ����� (like - � ��� �.�. ���?)
                    , p_limit       number                    default 10
                    , p_offset      number                    default 0
                    ) 
                    return          tbl_contractor_short      pipelined;

-- ����� ��������. �������� �.4.4.2 � �� �� ���������� ��� (�������� delivery_points_get)
-- �.�. 18.04.2017
type t_delivery_point is record(
                                  id          number
                                , address     varchar2(2000)
                                , phone       varchar2(400)
                                , email       varchar2(400)
                                , name        varchar2(400)
                                , total_cou   number                            -- ������ ���������� ��� ������������� ������
                                );
function DeliveryPointsGet(p_id t_loading_places.ldpl_id%type) return t_delivery_point;

-- ����� ��������. ��������� ��������� �.4.4.5 � �� �� ���������� ��� (�������� delivery_points)
-- �.�. 20.04.2017
type tbl_delivery_points is table of t_delivery_point;
function delivery_points(
            p_id_key      t_loading_places.ldpl_id%type         default null    -- ���� ������ �� ID ����� ��������
          , p_id_opr      varchar2                              default '='     -- �������� ������ �� ID {'>' | '<' | '='}
          , p_name_key    client_contacts.name%type             default '%'     -- ���� ������ �� ����� � ����� ��������
          , p_name_opr    varchar2                              default 'like'  -- �������� ������ �� ����� (like - � ��� �.�. ���?)
          , p_addr_key    t_loading_places.address_source%type  default '%'     -- ���� ������ �� ������ ����� ��������
          , p_addr_opr    varchar2                              default 'like'  -- �������� ������ �� ������ (like - � ��� �.�. ���?)
          , p_phone_key   client_contacts.phone%type            default '%'     -- ���� ������ �� �������� � ����� ��������
          , p_phone_opr   varchar2                              default 'like'  -- �������� ������ �� �������� (like - � ��� �.�. ���?)
          , p_email_key   client_contacts.email%type            default '%'     -- ���� ������ �� �������� � ����� ��������
          , p_email_opr   varchar2                              default 'like'  -- �������� ������ �� �������� (like - � ��� �.�. ���?)
          , p_sort_line   varchar2                              default 'id asc, name asc, address asc, phone asc, email asc'
          , p_limit       number                                default 10
          , p_offset      number                                default 0
          ) return        tbl_delivery_points pipelined
          ;

-- �������������. ��������� ���������. �. 4.10.1 � �� �� ���������� ��� (�������� debts)
-- �.�. 24.04.2017
type t_debts is record(
                        id        number                                        -- ID ������
                      , unit      varchar2(200)                                 -- ����� ����������
                      , sumDolg   number(15,2)                                        -- ����� ������������� � ������� ������
                      , date_end  date                                          -- ���� ������ �����
                      , status    varchar2(200)                                 -- ������ ������
                      , BaseCurrency varchar2(50)                              -- ������� ������
                      );
type tbl_debts is table of t_debts;
function Debts(
                p_id          number                                            -- ID �������
              , p_limit       number                                            -- ����� ������������ �����
              , p_start_with  number  default 1                                 -- ����� ������ ������������ ������
              ) return tbl_debts  pipelined
              ;

-- ��������� ������������. ��������� ���������. �. 4.3.1.1 � �� �� ���������� ���
-- ��������� ����������������� �� ������� ������� (�������� ��������: shippers)
type t_shippers is record(
                    id        clients.clnt_id%type,            -- ID ����������������
                    client_name      clients.client_name%type,     -- �������� �����������
                    official_address       clients.address%type,   -- ����������� �����
                    official_address_zip  clients.zip%type,        -- �������� ������ (����������� �����)
                    actual_address   clients.address_fact%type,    -- ����������� �����
                    actual_address_zip   clients.zip_fact%type    -- �������� ������ (����������� �����)
                   
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
                     
                     
-- ��������� ���������������� �� ������� ��������
-- �������� ��������: consignees	
type t_consignees is record(
                     clnt_id        clients.clnt_id%type,          -- ID ����������������
                     client_name      clients.client_name%type,    -- �������� �����������
                     official_address       clients.address%type,  -- ����������� �����
                     official_address_zip  clients.zip%type,       -- �������� ������ (����������� �����)
                     actual_address   clients.address_fact%type,   -- ����������� �����
                     actual_address_zip   clients.zip_fact%type   -- �������� ������ (����������� �����)
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
                     
-- ���������� ���� ������������ (���������������� � ���������������)
type t_persons is record(
                        id        client_contacts.clcn_id%type,     -- ID ����������� ����
                       name      varchar2(4000),                   -- ������ ��� ����������� ����
                       phone       client_contacts.phone%type,     -- ������� ����������� ����
                       email  client_contacts.email%type,          -- ����������� �����
                       position    client_contacts.job%type,       -- ��������� ���������� ���������� �����
					             is_decide    client_contacts.lpr%type      -- ����� ��������� �������? 0 - ��� 1 - ��
                      );

type tbl_persons is table of t_persons;
function getPersons(clnt_id number) return tbl_persons  pipelined;

-- ��, 21.06.2017
-- �����-���������� � ����������:
type t_files is record(
    file_id   doc_stores.dstr_id%type     -- ID �����
  , file_name doc_stores.file_name%type   -- ��� �����
  , file_size number                      -- ������ ����� � ������
);
type tbl_files is table of t_files;
function fn_doc_files(p_doc_id doc_stores.dcmt_dcmt_id%type) return tbl_files pipelined;

-- ============================================================
-- 20.10.2017 A.Starshinin
-- ���������� ����������� ������������� �� ������� �� �������� ����
-- ============================================================
-- ����������: SBCFinance
-- ����������: ���������� ����������� ������������� �� ������� �� �������� ����
-- ���������:  pStartDate - ���� ������ �������
--             pClntId - ��� �������
--             pHoldId - �������
--             pDate   - ����
--             pWarranty - �������� ������ null-���, 0-���,1-��
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
-- ���������� ����������� ������������� ����������� �� ������� ���� � ������� �����
-- �����: ��������� �.
-- ================================================================================
function GetClientDebetDolgEx(
   p_clnt_id in clients.clnt_id%type        -- ��� �����������
) return tbl_client_debet_dolg_ex pipelined parallel_enable;

--===================================================================================
-- ���� �������� ���������� �� ������
-- 24.11.17  �. ���������
--====================================================================================
function GetPOD_ord (
        pOrdid  t_orders.ord_id%type) return ports.def%type;
        
--=======================================================================================
-- 27.11.17 �. ���������
-- ������ �� ������, ������ � ����� ����������� ������
-- �������� �� ������� ����������� (���������) �� ������
-- ======================================================================================   
function GetFirstKonosament(pOrdId in t_orders.ord_id%type) return konosaments.knsm_id%type;

--- 02.02.2018 ������� ������ ���������� ���������� �� ������
function GetOrder_receivables (pOrdId in t_orders.ord_id%type,
                               pValueType in number) return number;
                               
type tTest is record (
   id                  t_orders.ord_id%type);

type tblTest is table of tTest;

function Test return tblTest pipelined parallel_enable; 
               
end MCSF_API;
/
create or replace package body MCSF_API is

-- ������ ������ ������� (orders) �� 4.7.3
--*********************************************************************************************************************
 function GetOrders(pClntId client_requests.clnt_clnt_id%type, -- ID �������
                     pFilter varchar2 default null,
                     pQueryFilter varchar2 default null,
                     pSortFilter varchar2 default null
                     ) 
   return tbl_orders pipelined parallel_enable is
 
   lQuery varchar2(32000);
   lQueryCols varchar2(32000);
   lQueryFrom varchar2(32000);
   lQueryWhere varchar2(32000);
 
   lCursor sys_refcursor;
   lRow    t_order_record;
   
   type tColsArr is table of varchar2(1200) index by varchar2(60);
   
   lColsArr tColsArr;
 
 begin
 
   lColsArr('id') := 'o.ord_id'; -- ��� ������ (id)
   lColsArr('place_from') := 'lp.address_source || '' '' || cit_lp.def || '' '' || cou_lp.def'; -- ����� ��������
   lColsArr('place_country_from') := 'cou_lp.def'; -- ������ ��������
   lColsArr('place_city_from') := 'cit_lp.def'; -- ����� ��������
   lColsArr('place_to') := 'dp.address_source || '' ''|| cit_dp.def || '' '' || cou_dp.def'; -- ����� ����������
   lColsArr('place_country_to') := 'cou_dp.def'; -- ������ ����������
   lColsArr('place_city_to') := 'cit_dp.def'; -- ����� ����������
   lColsArr('status') := 'ost.def'; -- ����������� ������
   lColsArr('status_id') := 'ost.orst_id'; -- ������������� �������
   lColsArr('date_closed') := 'o.complete_date'; -- ���� ���������� ������
   lColsArr('receivables') := 'mcsf_api.GetOrder_receivables(o.ord_id,0)'; -- ����� ������������� �� ������
   lColsArr('amount') := 'mcsf_api.GetOrder_receivables(o.ord_id,1)'; -- ���������� �����
   lColsArr('notification_count') := '(select count(*) 
                                          from MESSAGES2CUSTOMERS t
                                         where t.ord_ord_id = o.ord_id and
                                               t.send_date is not null and
                                               t.message_text not in (''NOT'',''message_text'')
                                       )'; -- ���-�� �����������
   lColsArr('cargo_name') := 'fr.def'; -- ������������ �����
   lColsArr('created_at') := 'cl.ord_date'; -- ���� �������� ������
   lColsArr('date_from') := 'lp.source_date_plan'; -- ���� �������� ������
   lColsArr('date_to') := 'dp.source_date_plan'; -- ���� �������� ������
   lColsArr('te_type') := '(case when con.cont_number is Null then null else con.cont_index || con.cont_number || '' (''||ctp.def||'')''end )'; -- ����� � ��� ��
   lColsArr('port_svh') := 'mcsf_api.GetPOD_ord(o.ord_id)'; -- ���� ���
   lColsArr('departure_country') := 'cou_lp.def'; -- ������ ����������� �����
   lColsArr('shipment_date') := '(select distinct first_value(k.pol_date) over (order by k.knsm_date asc) 
                                   from konosaments k, knsm_orders ko, knor_ord ord
                                  where ord.ord_ord_id = o.ord_id and
                                        ko.knor_id = ord.knor_knor_id and
                                        k.knsm_id = ko.knsm_knsm_id)'; -- ���� �������� �����
   lColsArr('unload_transhipment_plan_date') := '(select distinct first_value(k.pot_date) over (order by k.knsm_date asc) 
                                                   from konosaments k, knsm_orders ko, knor_ord ord
                                                  where ord.ord_ord_id = o.ord_id and
                                                        ko.knor_id = ord.knor_knor_id and
                                                        k.knsm_id = ko.knsm_knsm_id)'; -- ���� ������� � ���� ���������
   lColsArr('unload_destination_plan_date') := 'oc.arrival_date'; -- ���� ������� � ����/��� ���������� - ��� eta ��� arrival ����?
   lColsArr('unload_destination_fact_date') := 'nvl(vd.voch_date, ow1.voch_date)'; -- ���� �������� � �����/��� ���������� (����)
   lColsArr('date_dt') := 'g.gtd_date'; -- ��� �����
   lColsArr('date_release_dt') := 'g.date_out'; -- ���� ���
   lColsArr('dt_number') := 'g.gtd_number'; -- ���� ������� ���
   
   lColsArr('date_export_port') := 'ow3.date_out'; -- ���� ������ �� �����
   lColsArr('date_return_empty') := 'ow3.date_plan'; -- ���� �������� ���������
   lColsArr('customer_delivery_date') := 'c.date_in'; -- ���� �������� �� ����� - �������, ��� ��� ���� �������� � ������� ( � �������� "���� �������� � ����� ����������")
   
   lColsArr('am_number') := 'car.state_number'; -- ����� ��
   lColsArr('fio_driver') := 'c.driver_name'; -- ��� ��������
   
   lColsArr('consignor.id') := 'cl_lp.clnt_id';
   lColsArr('consignor.name') := 'cl_lp.client_name'; -- ���������������� (����������)
   
   lColsArr('consignee.id') := 'cl_dp.clnt_id';
   lColsArr('consignee.name') := 'cl_dp.client_name'; -- ��������������� (����������)
                                        
   lQueryCols := lColsArr('id') || ' id, ' ||
                 lColsArr('place_from') || ' place_from, ' ||
                 lColsArr('place_country_from') || ' place_country_from, ' ||
                 lColsArr('place_city_from') || ' place_city_from, ' ||
                 lColsArr('place_to') || ' place_to, ' ||
                 lColsArr('place_country_to') || ' place_country_to, ' ||
                 lColsArr('place_city_to') || ' place_city_to, ' ||
                 lColsArr('status') || ' status, ' ||
                 lColsArr('status_id') || ' status_id, ' ||
                 lColsArr('date_closed') || ' date_closed, ' ||
                 lColsArr('receivables') || ' receivables, ' ||
                 lColsArr('amount') || ' amount, ' ||
                 lColsArr('notification_count') || ' notification_count, ' ||
                 lColsArr('cargo_name') || ' cargo_name, ' ||
                 lColsArr('created_at') || ' created_at, ' ||
                 lColsArr('date_from') || ' date_from, ' ||
                 lColsArr('date_to') || ' date_to, ' ||
                 lColsArr('te_type') || ' te_type, ' ||
                 lColsArr('port_svh') || ' port_svh, ' ||
                 lColsArr('departure_country') || ' departure_country, ' ||
                 lColsArr('shipment_date') || ' shipment_date, ' ||
                 lColsArr('unload_transhipment_plan_date') || ' unload_transhipment_plan_date, ' ||
                 lColsArr('unload_destination_plan_date') || ' unload_destination_plan_date, ' ||
                 lColsArr('unload_destination_fact_date') || ' unload_destination_fact_date, ' ||
                 lColsArr('date_dt') || ' date_dt, ' ||
                 lColsArr('date_release_dt') || ' date_release_dt, ' ||
                 lColsArr('dt_number') || ' dt_number, ' ||
                 lColsArr('date_export_port') || ' date_export_port, ' ||
                 lColsArr('date_return_empty') || ' date_return_empty, ' ||
                 lColsArr('customer_delivery_date') || ' customer_delivery_date, ' ||
                 lColsArr('am_number') || ' am_number, ' ||
                 lColsArr('fio_driver') || ' fio_driver, ' ||
                 lColsArr('consignor.id') || ' "consignor.id", ' ||
                 lColsArr('consignor.name') || ' "consignor.name", ' ||
                 lColsArr('consignee.id') || ' "consignee.id", ' ||
                 lColsArr('consignee.name') || ' "consignee.name" ';
   
   lQueryFrom := 't_orders o, 
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
                  conteiner_types ctp,
                  order_statuses ost,
                  order_cnsm_mv oc,  -- ������ �� ������ ��������
                  vVouchers vd,
                  order_ways ow1,
                  order_ways ow3,
                  vord_gtd vgt,
                  gtds g,
                  cmrs c,
                  cars car,
                  vcmrs_last cmrl,
                  clients cl_lp,
                  clients cl_dp
                  ';
                  
   lQueryWhere := 'cl.clnt_clnt_id   = :pClntId 
                  and co.clrq_clrq_id   = cl.clrq_id 
                  and o.ord_id          = co.ord_ord_id
                  and o.cont_cont_id    = con.cont_id(+)
                  and con.cntp_cntp_id  = ctp.cntp_id(+)
                  and o.ord_id          = vsl.ord_ord_id(+)
                  and vsl.orst_orst_id  = ost.orst_id(+)
                  and o.ord_id          = vofr.ord_ord_id(+)
                  and vofr.frgt_frgt_id = fr.frgt_id(+)
                  -- ����������������
                  and o.ord_id          = lp.ord_ord_id(+)
                  and lp.source_type(+) = 0
                  and lp.ldpl_type(+)   = 0
                  and lp.del_date(+) is Null
                  and lp.source_clnt_id = cl_lp.clnt_id(+)
                  and lp.city_city_id   = cit_lp.city_id(+)
                  and cit_lp.cou_cou_id = cou_lp.cou_id(+)
                  -- ���������������
                  and o.ord_id          = dp.ord_ord_id(+)
                  and dp.source_type(+) = 0
                  and dp.ldpl_type(+)   = 1
                  and dp.del_date(+) is Null
                  and dp.source_clnt_id = cl_dp.clnt_id(+)
                  and dp.city_city_id   = cit_dp.city_id(+)
                  and cit_dp.cou_cou_id = cou_dp.cou_id(+)
                  and o.ord_id          = oc.ord_id(+)
                  and o.ord_id          = ow1.ord_ord_id(+)
                  -- ��
                  and o.ord_id          = vd.ord_ord_id(+)
                  -- ���
                  and o.ord_id          = vgt.ord_ord_id(+)
                  and vgt.gtd_gtd_id    = g.gtd_id(+)
                  -- �����
                  and o.ord_id          = ow3.ord_ord_id(+)
                  and ow3.orws_type(+)  = 3
                  and ow3.del_user(+) is Null
                  -- ������ � ��������
                  and ow3.orws_id         = cmrl.orws_orws_id(+)
                  and cmrl.cmr_id         = c.cmr_id(+)
                  and c.car_car_id        = car.car_id(+)
                  ';
   
   lQuery := 'select ' || lQueryCols || ' from ' || lQueryFrom || ' where ' || lQueryWhere;
   
   if pQueryFilter is not null then
     lQuery := lQuery || ' and lower(' ||
               lColsArr('id') || ' || '' '' || ' ||
               lColsArr('place_from') || ' || '' '' || ' ||
               lColsArr('place_to') || ' || '' '' || ' ||
               lColsArr('status') || ' || '' '' || ' ||
               lColsArr('status_id') || ' || '' '' || ' ||
               'to_char(' || lColsArr('date_closed') || ', ''' || PkgDefaultDateFormat || ''')' || ' || '' '' || ' ||
               lColsArr('receivables') || ' || '' '' || ' ||
               lColsArr('amount') || ' || '' '' || ' ||
               lColsArr('notification_count') || ' || '' '' || ' ||
               lColsArr('cargo_name') || ' || '' '' || ' ||
               'to_char(' || lColsArr('created_at') || ', ''' || PkgDefaultDateFormat || ''')' || ' || '' '' || ' ||
               'to_char(' || lColsArr('date_from') || ', ''' || PkgDefaultDateFormat || ''')' || ' || '' '' || ' ||
               'to_char(' || lColsArr('date_to') || ', ''' || PkgDefaultDateFormat || ''')' || ' || '' '' || ' ||
               lColsArr('te_type') || ' || '' '' || ' ||
               lColsArr('port_svh') || ' || '' '' || ' ||
               lColsArr('departure_country') || ' || '' '' || ' ||
               'to_char(' || lColsArr('shipment_date') || ', ''' || PkgDefaultDateFormat || ''')' || ' || '' '' || ' ||
               'to_char(' || lColsArr('unload_transhipment_plan_date') || ', ''' || PkgDefaultDateFormat || ''')' || ' || '' '' || ' ||
               'to_char(' || lColsArr('unload_destination_plan_date') || ', ''' || PkgDefaultDateFormat || ''')' || ' || '' '' || ' ||
               'to_char(' || lColsArr('unload_destination_fact_date') || ', ''' || PkgDefaultDateFormat || ''')' || ' || '' '' || ' ||
               'to_char(' || lColsArr('date_dt') || ', ''' || PkgDefaultDateFormat || ''')' || ' || '' '' || ' ||
               'to_char(' || lColsArr('date_release_dt') || ', ''' || PkgDefaultDateFormat || ''')' || ' || '' '' || ' ||
               lColsArr('dt_number') || ' || '' '' || ' ||
               'to_char(' || lColsArr('date_export_port') || ', ''' || PkgDefaultDateFormat || ''')' || ' || '' '' || ' ||
               'to_char(' || lColsArr('date_return_empty') || ', ''' || PkgDefaultDateFormat || ''')' || ' || '' '' || ' ||
               'to_char(' || lColsArr('customer_delivery_date') || ', ''' || PkgDefaultDateFormat || ''')' || ' || '' '' || ' ||
               lColsArr('consignor.id') || ' || '' '' || ' ||
               lColsArr('consignor.name') || ' || '' '' || ' ||
               lColsArr('consignee.id') || ' || '' '' || ' ||
               lColsArr('consignee.name') || ' || '' '' || ' ||
               lColsArr('am_number') || ' || '' '' || ' ||
               lColsArr('fio_driver') || '
             ) like lower(''%' || pQueryFilter || '%'')';
   end if;
   
   if pFilter is not null then
     lQuery := 'select * from (' || lQuery || ') where ' || pFilter;
   end if;
   
   if pSortFilter is not null then
     lQuery := lQuery || ' order by ' || pSortFilter;
   end if;  
 
   open lCursor for lQuery using pClntId;
 
   loop fetch lCursor into lRow; exit when lCursor%notfound; pipe row(lRow); end loop;
 
   close lCursor;
 
   return;
 end;
--*********************************************************************************************************************


-- ��������� ���������� �� ������ (orders_get) �� 4.7.2
--*********************************************************************************************************************
 function GetOrderById(pID t_orders.ord_id%type, pClntId clients_dic.clnt_id%type) return tbl_orders_extended pipelined parallel_enable  
 is 
  vRow t_order_extended_record;
  vRow_rummage t_mcsf_api_rummage;
  vRow_doc t_mcsf_api_order_doc;
  vRow_cargo t_cargo;
  --vRow_messages t_message;
  vRow_doc_files tbl_mcsf_api_order_doc_files;
-- Invoices. YK, 22.07.2017:
  vRow_invcs_in_ord t_mcsf_api_invoice; -- ����� � ������������ ������
  vTab_ords_in_invc tbl_mcsf_api_order_ids; -- ������ � ������ ������������� ������
  i integer;
 begin
    for cur in (
      select o.ord_id id,-- ������������� ������
             cl_lp.clnt_id "consignor.id",  
             cl_lp.client_name "consignor.name",-- ���������������� (����������) 
             cl_dp.clnt_id "consignee.id",       
             cl_dp.client_name "consignee.name",-- ��������������� (����������)        
             cl.ord_date created_at,-- ���� �������� ������      
             o.complete_date date_closed,  -- ���� ���������� ������ 
             /*
             25.11.17  ���������� � ������������� ������ �� ��
             ���� ����� ��������� - ����� ������ ������ �� ������
             ost.def status,-- C����� ������    
                                      
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
                            and cp.krnt_krnt_id is Null), 0) receivable_cost, -- ����� ������������� 
             nvl((select sum(round(cp.summa_oper/i.base_rate, 2))
                          from invoice_details id,
                               invoices i,                                 
                               cash_prixods cp
                          where id.ord_ord_id   = o.ord_id
                            and id.invc_invc_id = i.invc_id
                            and i.intp_intp_id  = 1
                            and i.del_user is Null
                            and cp.indt_indt_id = id.indt_id
                            and cp.krnt_krnt_id is Null), 0) amount_cost, -- ���������� �����     
             sysdate receivable_date,
             '������ �������������' receivable_status,-- ������ ������������� 
             */
            (select distinct first_value(p.def) over (order by k.knsm_date asc) 
             from konosaments k, knsm_orders ko, knor_ord ord, ports p
            where ord.ord_ord_id = o.ord_id and
                  ko.knor_id = ord.knor_knor_id and
                  k.knsm_id = ko.knsm_knsm_id and
                  p.port_id (+)= k.pol_port_id) departure_port,-- ���� �����������
            (select distinct first_value(cou.def) over (order by k.knsm_date asc) 
             from konosaments k, knsm_orders ko, knor_ord ord, cities c, countries cou
            where ord.ord_ord_id = o.ord_id and
                  ko.knor_id = ord.knor_knor_id and
                  k.knsm_id = ko.knsm_knsm_id and
                  c.city_id (+)= k.city_pol_id and
                  cou.cou_id (+)= c.cou_cou_id) departure_country,-- ������ �����������                  
             ct.def container_type,-- ��� ����������      
             con.cont_index container_prefix,-- ������� ����������    
             con.cont_number container_number,-- ����� ����������  
            (select distinct first_value(k.pol_date) over (order by k.knsm_date asc) 
             from konosaments k, knsm_orders ko, knor_ord ord
            where ord.ord_ord_id = o.ord_id and
                  ko.knor_id = ord.knor_knor_id and
                  k.knsm_id = ko.knsm_knsm_id) date_shipment,-- ���� �������� �����         
             (select distinct first_value(k.pot_date) over (order by k.knsm_date asc) 
             from konosaments k, knsm_orders ko, knor_ord ord
            where ord.ord_ord_id = o.ord_id and
                  ko.knor_id = ord.knor_knor_id and
                  k.knsm_id = ko.knsm_knsm_id) date_transshipment,-- ���� ������� � ���� ���������
             oc.arrival_date date_arrival,-- ���� ��������       
             nvl(vd.voch_date, ow1.voch_date) date_upload,-- ���� ��������       
             ow3.date_out date_export,-- ���� ������  
             c.date_in customer_delivery_date, -- ���� �������� �������
             ow3.date_plan date_submission,-- ���� ����� ���������    
             cit_pod.def arrival_city,-- ����� ��������      
             p_pod.def arrival_port,-- ���� ��������       
             -- s.def arrival_ship,-- ����� (�����)       
             g.gtd_number gtd_number,-- ��� �����        
             g.gtd_date gtd_date,  -- ���� ���    
             g.date_out gtd_issuance, -- ���� ������� ���
             c.driver_name,
             c.driver_phone,
             car.state_number                   
         from t_orders o,
             clrq_orders co, 
             client_requests cl,  
             order_ways ow1,    
             order_ways ow3,    
             t_loading_places lp,
             t_loading_places dp,
             order_cnsm_mv oc,  -- ������ �� ������ ��������
             vord_gtd vgt,
             gtds g,
             vVouchers vd,
             vOrder_Statuses_Last vsl,
             conteiners con,
             cities cit_pod,
             ports p_pod,  --- ���� ��������
             clients cl_lp,
             clients cl_dp,
             ships s,
             conteiner_types ct,
             order_statuses ost,
             cmrs c,
             cars car,
             vcmrs_last cmrl
       where o.ord_id = pID 
         and co.clrq_clrq_id   = cl.clrq_id 
         and cl.clnt_clnt_id   = pClntId      -- ����� ������ �� ������ �� �� ������, �� � �� �� �������
         and o.ord_id          = co.ord_ord_id
         and o.ord_id          = vsl.ord_ord_id(+)
         and vsl.orst_orst_id  = ost.orst_id(+)
         and o.cont_cont_id    = con.cont_id(+)
         and con.cntp_cntp_id  = ct.cntp_id(+)
         and o.ord_id          = ow1.ord_ord_id(+)
         and ow1.orws_type(+)  = 1
         and ow1.del_user(+) is Null
         -- ����������������
         and o.ord_id          = lp.ord_ord_id(+)
         and lp.source_type(+) = 0
         and lp.ldpl_type(+)   = 0
         and lp.del_date(+) is Null
         and lp.source_clnt_id = cl_lp.clnt_id(+)
         -- ���������������
         and o.ord_id          = dp.ord_ord_id(+)
         and dp.source_type(+) = 0
         and dp.ldpl_type(+)   = 1
         and dp.del_date(+) is Null
         and dp.source_clnt_id = cl_dp.clnt_id(+)
         -- ����������
         and o.ord_id            = oc.ord_id(+)
         and oc.pod_port_id      = p_pod.port_id(+)
         and oc.city_pod_id      = cit_pod.city_id(+)
         and oc.trsp_trsp_id     = s.trsp_id(+)
          /* 
         and oc.pol_port_id      = p_pol.port_id(+)
         and oc.city_pol_id      = cit_pol.city_id(+)
         and cou_pol.cou_id      = cit_pol.cou_cou_id(+)
         */
         -- ��
         and o.ord_id            = vd.ord_ord_id(+)
         -- ���
         and o.ord_id            = vgt.ord_ord_id(+)
         and vgt.gtd_gtd_id      = g.gtd_id(+)
         -- �����
         and o.ord_id            = ow3.ord_ord_id(+)
         and ow3.orws_type(+)    = 3
         and ow3.del_user(+) is Null
         -- ������ � ��������
         and ow3.orws_id         = cmrl.orws_orws_id(+)
         and cmrl.cmr_id         = c.cmr_id(+)
         and c.car_car_id        = car.car_id(+)
                  
         )
    loop
       vRow.id := cur.id;                 -- ������������� ������
       vRow.consignor := t_mcsf_api_contractor_short(cur."consignor.id", cur."consignor.name");   -- ���������������� (����������)
       vRow.consignee := t_mcsf_api_contractor_short(cur."consignee.id", cur."consignee.name");   -- ��������������� (����������)
       vRow.created_at := cur.created_at; -- ���� �������� ������
       vRow.date_closed := cur.date_closed;  -- ���� �������� ������
     --  vRow.status := cur.status;         -- ������� ������ ������ 
       -- ��������� ���������  -------------------------
       /*
       ����� 4.7.2 � ������ ����� �������� messages
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
             vRow_messages := t_message(c1.mscm_id,         --������������� ���������
                                        c1.from_mes,        -- ��� �����������
                                        c1.send_to,         -- ����� ����������
                                        c1.message_text,    -- ����� ���������
                                        c1.created_at,    -- ���� �������� ���������
                                        c1.status_mes,        -- ��������� ���������
                                        c1.order_id);       -- ������������� ������
             
             i := i + 1;                            
             vRow.messages.extend;
             vRow.messages(i) :=  vRow_messages;
       end loop;   */   
       -- ���������� � ����� ---------------------------
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
       -- ���������� � �� ------------------------------
       for c3 in (select ct.def || ' ' || c.cont_index || c.cont_number unit_info
                    from t_orders o, conteiners c, conteiner_types ct
                   where o.ord_id = vRow.id and
                         c.cont_id (+)= o.cont_cont_id and
                         ct.cntp_id (+)= c.cntp_cntp_id ) loop
           vRow.unit := t_mcsf_api_unit(c3.unit_info);
       end loop;    
       -- ����������� ��������� ------------------------
       vRow.doc       := tbl_mcsf_api_order_docs();
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
                         
          select mcsf_api_helper.GetDocFiles(c4.id) into vRow_doc_files from dual;               
          
          vRow_doc := t_mcsf_api_order_doc(c4.id, -- �������������
                                            c4.order_id, -- ������������� ������
                                            c4.type_id,  -- ������������� ���� ���������
                                            c4.doc_type, -- ������������ ���������
                                            c4.doc_date, -- ���� ���������
                                            c4.uploaded_at, -- ���� ��������
                                            c4.owner,         -- �������� ���������
                                            vRow_doc_files
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
       -- ���� ��������  -------------------------------
       vRow.rummages  := tbl_mcsf_api_rummages();
       i := 0;
       for rd in (select ct.def type_rummage, co.chot_date date_rummage
                    from check_outs co, check_out_types ct
                   where co.ord_ord_id = cur.id and
                         ct.chtp_id = co.chtp_chtp_id)
        loop
         vRow_rummage := t_mcsf_api_rummage(rd.type_rummage,    -- ��� ��������
                                        rd.date_rummage -- ���� ��������
                                        );
         i := i + 1;                               
         vRow.rummages.extend;
         vRow.rummages(i) := vRow_rummage;
        end loop;
        
        -- ���������� �� ������
        vRow.invoices := tbl_mcsf_api_invoices();
        for c in (
          select rownum as rn, invc_id as id, price as total,
                (select sum(oplacheno) from invoice_details where invoice_details.invc_invc_id = inv.invc_id) as paid, 
                 pay_date as pay_to, 
                 (select def from currencies where currencies.cur_id = inv.cur_cur_id) as currency
           from invoices inv where inv.intp_intp_id = 1 and inv.invc_id in
                (select invc_invc_id from invoice_details id where ord_ord_id = pID)
        ) loop
          
          select mcsf_api_helper.GetInvoiceOrderIds(c.id) into vTab_ords_in_invc from dual;
          
          vRow_invcs_in_ord := t_mcsf_api_invoice(c.id, c.total, c.paid, c.pay_to, c.currency, vTab_ords_in_invc);
          
          vRow.invoices.extend;
          vRow.invoices(c.rn) := vRow_invcs_in_ord;
        end loop;
        
        -- ���������� �� ������ � ��������
        vRow.delivery_car := t_mcsf_api_delivery_car(cur.driver_name, cur.state_number, cur.driver_phone);
         
      pipe row (vRow);      
    end loop;
    return;      
    
 end;
 
--********************************************************************************************************************* 


-- ������ ������ ���������� (orders_docs) �� 4.8.5
--*********************************************************************************************************************
 function GetDocuments(pClntId client_requests.clnt_clnt_id%type, -- ID �������
                     pFilter varchar2 default null,
                     pQueryFilter varchar2 default null,
                     pSortFilter varchar2 default null
                     ) 
   return tbl_mcsf_api_order_docs pipelined parallel_enable is
   
   lQuery varchar2(32000);
   lQueryCols varchar2(32000);
   lQueryFrom varchar2(32000);
   lQueryWhere varchar2(32000);
 
   lCursor sys_refcursor;
   
   lRow    t_mcsf_api_order_doc;
   lRowRec mcsf_api_helper.t_mcsf_api_order_doc_rec;
   lRowFiles tbl_mcsf_api_order_doc_files;
   
   type tColsArr is table of varchar2(1200) index by varchar2(60);
   
   lColsArr tColsArr;
   
 begin
   lColsArr('id') := 'd.dcmt_id';
   lColsArr('order_id') := 'dl.ord_ord_id';
   lColsArr('type_id') := 'd.dctp_dctp_id';
   lColsArr('doc_type') := 'dt.def';
   lColsArr('doc_date') := 'd.doc_date';
   lColsArr('uploaded_at') := 'd.navi_date';
   lColsArr('owner') := 'd.navi_user';
   lColsArr('files') := 'NULL';
   
   lQueryCols := lColsArr('id')          || ' id, '               ||
                 lColsArr('order_id')    || ' order_id, '         || 
                 lColsArr('type_id')     || ' type_id, '          ||
                 lColsArr('doc_type')    || ' doc_type, '         ||
                 lColsArr('doc_date')    || ' doc_date, '         ||
                 lColsArr('uploaded_at') || ' uploaded_at, '      ||
                 lColsArr('owner')       || ' owner ';
                 
   lQueryFrom := '
                 documents       d,
                 doc_links       dl,
                 doc_types       dt,
                 t_orders        o,
                 clrq_orders     clrq,
                 client_requests cl
   ';
   
   lQueryWhere := '
                 d.doc_state = 0
                 and d.del_user is null
                 and d.del_date is null
                 and dl.dcmt_dcmt_id = d.dcmt_id
                 and o.ord_id = dl.ord_ord_id
                 and clrq.ord_ord_id = o.ord_id
                 and cl.clrq_id = clrq.clrq_clrq_id
                 and cl.clnt_clnt_id = :pClntId
                 and dt.dctp_id = d.dctp_dctp_id
   ';
   
   lQuery := 'select ' || lQueryCols || ' from ' || lQueryFrom || ' where ' || lQueryWhere;
   
   if pQueryFilter is not null then
     lQuery := lQuery || ' and lower(' ||
               lColsArr('id') || ' || '' '' || ' ||
               lColsArr('order_id') || ' || '' '' || ' ||
               lColsArr('doc_type') || ' || '' '' || ' ||
               'to_char(' || lColsArr('uploaded_at') || ', ''' || PkgDefaultDateFormat || ''')' || ' || '' '' || ' ||
               lColsArr('order_id') || ' || '' '' || ' ||
               lColsArr('owner') || ' || '' '' || ' ||
               lColsArr('files') || '
             ) like lower(''%' || pQueryFilter || '%'')';
   end if;
   
   if pFilter is not null then
     lQuery := 'select * from (' || lQuery || ') where ' || pFilter;
   end if;
   
   if pSortFilter is not null then
     lQuery := lQuery || ' order by ' || pSortFilter;
   end if;
   
   open lCursor for lQuery using pClntId;
 
   loop 
     fetch lCursor into lRowRec; 
     
     exit when lCursor%notfound;
     
     select mcsf_api_helper.GetDocFiles(lRowRec.id) into lRowFiles from dual;
     
     lRow := t_mcsf_api_order_doc(
          lRowRec.id, 
          lRowRec.order_id, 
          lRowRec.type_id, 
          lRowRec.doc_type, 
          lRowRec.doc_date, 
          lRowRec.uploaded_at, 
          lRowRec.owner,
          lRowFiles
     ); 
     pipe row(lRow); 
   end loop;
   
   close lCursor;
   
 end;

--*********************************************************************************************************************


-- ������ ������ ���������� (orders_docs) �� 4.8.1
--*********************************************************************************************************************
function GetDocument(pClntId clients_dic.clnt_id%type,
                     pId documents.dcmt_id%type) return t_mcsf_api_order_doc is

   lCursor sys_refcursor;
   
   lRow    t_mcsf_api_order_doc := null;
   lRowRec mcsf_api_helper.t_mcsf_api_order_doc_rec;
   lRowFiles tbl_mcsf_api_order_doc_files;

begin
   
   open lCursor for select d.dcmt_id id, 
                      dl.ord_ord_id order_id,
                      d.dctp_dctp_id type_id,
                      dt.def doc_type,
                      d.doc_date doc_date,
                      d.navi_date uploaded_at,
                      d.navi_user owner 
                 from documents d, doc_links dl, doc_types dt,t_orders o, clrq_orders clrq, client_requests cl
                where d.dcmt_id = pId and
                      d.doc_state = 0 and
                      d.del_user is null and
                      d.del_date is null and
                      dl.dcmt_dcmt_id = d.dcmt_id and
                      o.ord_id = dl.ord_ord_id and
                      clrq.ord_ord_id = o.ord_id and
                      cl.clrq_id = clrq.clrq_clrq_id and
                      cl.clnt_clnt_id = pClntId and
                      dt.dctp_id = d.dctp_dctp_id;
 
   loop 
     fetch lCursor into lRowRec; 
     
     exit when lCursor%notfound;
     
     select mcsf_api_helper.GetDocFiles(lRowRec.id) into lRowFiles from dual;
     
     lRow := t_mcsf_api_order_doc(
          lRowRec.id, 
          lRowRec.order_id, 
          lRowRec.type_id, 
          lRowRec.doc_type, 
          lRowRec.doc_date, 
          lRowRec.uploaded_at, 
          lRowRec.owner,
          lRowFiles
     ); 
     
   end loop;
   
   close lCursor;
   
   return lRow;
         
end;

--*********************************************************************************************************************


-- �������� ��������� (orders_doc_create) �� 4.8.1
--*********************************************************************************************************************
function CreateDocument(pOrdId t_orders.ord_id%type,   -- �������������� ��������� ������
                        pClntId clients_dic.clnt_id%type, -- �������������� ��������� �������
                        pDctpId doc_types_dic.dctp_id%type, -- ��� ���������
                        pDocnumber documents.doc_number%type default null, -- ����� ���������
                        pDocDate documents.doc_date%type default sysdate, -- ���� ���������
                        pTheme documents.theme%type default null,  -- ���� ���������
                        pShortContent documents.shrt_content%type default null, -- ������� �������� ��������� (����������) 
                        pAuthor documents.author%type default null -- ����� ���������
                        ) return number is
                        
lDocId documents.dcmt_id%type;
lHoldId holding_dic.hold_id%type;       
                 
begin
  -- �������� �������������� ������ �������, �������� ������������ ������� ������������ �������
  
  if mcsf_api_helper.CheckOwnerOrder(pOrdId,pClntId) then
     
     begin
         
         select dcmt_seq.nextval into lDocId from dual;
         
         -- �������������� ������� ��������
         select cl.hold_hold_id
           into lHoldId
           from clients_dic cl
          where cl.clnt_id = pClntId;
          
         -- ����������� ��������� 
         insert into documents
               (dcmt_id,doc_number,doc_date,dctp_dctp_id,theme,shrt_content,
                author,navi_user,navi_date,doc_state,hold_hold_id)
         values(lDocId,pDocnumber,pDocDate,pDctpId,pTheme,pShortContent,
                pAuthor,user,sysdate,0,lHoldId);
                
         -- �������� ����� ��������� � �������
         insert into doc_links
                (dcln_id,dcmt_dcmt_id,ord_ord_id,navi_user,navi_date)
          values(dcln_seq.nextval,lDocId,pOrdId,user,sysdate);
          
         commit;
         
         return lDocId;
     
     exception
        when no_data_found then
          return -1;
         
     end; 
                
  else
    
     return -1;
     
  end if;  
       
end;

--*********************************************************************************************************************


-- ���������� ��������� (orders_doc_create) �� 4.8.2
--*********************************************************************************************************************
function UpdateDocument(pClntId clients_dic.clnt_id%type,     -- �������������� ��������� �������, 
                        pDocId documents.dcmt_id%type,        -- ������������� ���������
                        pDctpId doc_types_dic.dctp_id%type, -- ��� ���������
                        pDocnumber documents.doc_number%type default null, -- ����� ���������
                        pDocDate documents.doc_date%type default sysdate, -- ���� ���������
                        pTheme documents.theme%type default null,  -- ���� ���������
                        pShortContent documents.shrt_content%type default null, -- ������� �������� ��������� (����������) 
                        pAuthor documents.author%type default null -- ����� ���������
                        ) return boolean is
                        
 lHoldId holding_dic.hold_id%type;  
 v_errm varchar2(2000); 
 lOrdId t_orders.ord_id%type;
                       
begin
         -- ������ ������ ����������� ��������
         select dl.ord_ord_id
           into lOrdId
           from doc_links dl
         where dl.dcmt_dcmt_id = pDocId;  
         
         if mcsf_api_helper.CheckOwnerOrder(lOrdId, pClntId) then
           
            begin
               -- �������������� ������� ��������
               select cl.hold_hold_id
                 into lHoldId
                 from clients_dic cl
                where cl.clnt_id = pClntId;
                
               -- ���������� ��������� 
               update documents d
                  set d.doc_number = pDocnumber,
                      d.doc_date = pDocDate,
                      d.dctp_dctp_id = pDctpId,
                      d.theme = pTheme,
                      d.shrt_content = pShortContent,
                      d.author = pAuthor,
                      d.navi_user = user,
                      d.navi_date = sysdate,
                      d.hold_hold_id = lHoldId
                where d.dcmt_id = pDocId and
                      d.del_user is null and
                      d.del_date is null;
                
               commit;
               
               return true;
            end;
            
         else   
            -- �������� �� ������ �� ����������� ��������� �������   
            return false;
            
         end if;  
          
exception
  when others then
    begin
      v_errm := SQLERRM;
      insert into sys_logs (slog_id,msg,log_date,appl_appl_id,apmt_apmt_id) values(slog_seq.nextval,v_errm,sysdate,20,1);
      commit;       
      return false;
    end;
             
end;                         

--********************************************************************************************************************* 


-- �������� ��������� (orders_doc_delete) �� 4.8.4
--*********************************************************************************************************************                       
function RemoveDocument(pClntId clients_dic.clnt_id%type,  -- �������������� ��������� �������
                        pDocId documents.dcmt_id%type      -- ������������� ���������
                        ) return boolean is
                        
 v_errm varchar2(2000); 
 lOrdId t_orders.ord_id%type;
 
begin
  
    -- ������ ������ ����������� ��������
    select dl.ord_ord_id
      into lOrdId
      from doc_links dl
     where dl.dcmt_dcmt_id = pDocId;
       
    if mcsf_api_helper.CheckOwnerOrder(lOrdId, pClntId) then
       
       begin
         
         -- ���������� ��������
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
      insert into sys_logs (slog_id,msg,log_date,appl_appl_id,apmt_apmt_id) values(slog_seq.nextval,v_errm,sysdate,20,1);
      commit;       
      return false;
    end; 
                    
end;

--********************************************************************************************************************* 


-- ���������� ����� � �������� �� ������ (orders_doc_addfile) �� 4.8.6
--*********************************************************************************************************************  
function AddFileToDocument (pClntId clients_dic.clnt_id%type, -- �������������� ��������� �������    
                            pDocId documents.dcmt_id%type,    -- ������������� ���������
                            pFileBody doc_stores.doc_data%type, -- ���������� ����� ��� ��������
                            pFileName doc_stores.file_name%type      -- ��� �����
                            ) return integer is
                            
lFileId doc_stores.dstr_id%type;

v_errm varchar2(2000); 
lOrdId t_orders.ord_id%type;     
             
begin
  
  -- ������ ������ ����������� ��������
  select dl.ord_ord_id
    into lOrdId
    from doc_links dl
   where dl.dcmt_dcmt_id = pDocId;
   
  if mcsf_api_helper.CheckOwnerOrder(lOrdId, pClntId) then
  
    select dstr_seq.nextval into lFileId from dual;
    
    insert into doc_stores (dstr_id, dcmt_dcmt_id,file_name, doc_data,navi_user,navi_date)
    values(lFileId,pDocId,pFileName,pFileBody,user,sysdate);
     
    return lFileId;
   
  end if;
  
  return -1;
   
exception
   when others then
      v_errm := SQLERRM;
      insert into sys_logs (slog_id,msg,log_date,appl_appl_id,apmt_apmt_id) values(slog_seq.nextval,v_errm,sysdate,20,1);
      commit;
      return -1;   
end;

--*********************************************************************************************************************


-- ��������� ����� � �������� �� ������ (orders_doc_getfile) �� 4.8.7
--********************************************************************************************************************* 
procedure GetFile(pClntId in clients_dic.clnt_id%type,    -- �������������� ��������� �������
                  pFileId in doc_stores.dstr_id%type,     -- ������������� ������������ �����
                  pFileBody out doc_stores.doc_data%type, -- ���������� ������������ �����
                  pFileName out doc_stores.file_name%type  -- ��� �����
                  ) is
                  
  lOrdId t_orders.ord_id%type; 
   
begin
  
  -- ������ ������ ����������� ��������
  select dl.ord_ord_id
    into lOrdId
    from doc_links dl
   where dl.dcmt_dcmt_id = (select ds.dcmt_dcmt_id from doc_stores ds where ds.dstr_id = pFileId);
   
  if mcsf_api_helper.CheckOwnerOrder(lOrdId, pClntId) then
  
    pFileBody := documents_api.Get_Documents_Data(pFileId);
   
   select ds.file_name 
     into pFileName
     from doc_stores ds
    where ds.dstr_id = pFileId;
   
  end if;
  
exception
  when others then
    begin
      pFileBody := null;
      pFilename := null;
    end;    
end; 

--*********************************************************************************************************************

-- ����������� �� 4.15
--*********************************************************************************************************************  
function �ountriesDic return tbl_countries pipelined parallel_enable is
begin
  for cur in (select cou_id, def 
                from countries
                order by  def)
     loop
        pipe row(cur);
     end loop; 
     return;            
end;

-- ������� �������� ����������� ��������
function RegionsDic return tbl_regions pipelined parallel_enable is
begin
  for cur in (select cn.cntn_id, cn.region_name 
                from continents cn
                order by  cn.region_name)
     loop
        pipe row(cur);
     end loop; 
     return;            
end; 

-- ������� �������� ����������� �������
function CitiesDic return tbl_cities pipelined parallel_enable is
begin
  for cur in (select c.city_id, c.def 
                from cities c
                order by c.def)
     loop
        pipe row(cur);
     end loop; 
     return;            
end;  

-- ������� �������� ������ ����������� ����� ����������
function DocTypesDic return tbl_doc_types pipelined parallel_enable is
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

-- ������� �������� ����������� ������
function StatusesDic return tbl_statuses pipelined parallel_enable is
begin
  for cur in (select os.orst_id id, os.def "name" from order_statuses os order by os.orst_id)
      loop
        pipe row(cur);
      end loop;
      return;            
end;

--********************************************************************************************************************* 


-- ������� ������ ������ �� �������� �� 4.2.1
--*********************************************************************************************************************                           
function GetCompanies(pClntId clients_dic.clnt_id%type) return tbl_companies pipelined parallel_enable is
  
lTotalOrders number;

 -- ������� �������� ���������� ������� �� ������� ��������
 function GetTotalOrders(pClntId in clients.clnt_id%type) return number is
 begin
   select count(cr.clrq_id) 
     into lTotalOrders
     from client_requests cr
    where cr.clnt_clnt_id = pClntId and
          cr.del_date is null; 
   return lTotalOrders;
 exception
   when others then
     return 0;  
 end; 
  
begin
  
  lTotalOrders := GetTotalOrders(pClntId);
  
  for cur in (select cl.clnt_id,                          --  �� ��������
                     cl.client_name,                      -- �������� ��������
                     null phone,                          -- ������� ������� (�������� � ����� ������� �������)
                     tp.def tarif_plan,                   -- �������� ����                    
                     lTotalOrders total_orders            -- ���-�� ������� �� ��� ������� ������
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

--********************************************************************************************************************* 


-- ������� ������ ������ �� �������� �� 4.2.1
--*********************************************************************************************************************  
function GetCompanyContacts(pClntId clients_dic.clnt_id%type) return tbl_company_contacts pipelined parallel_enable is
begin
  for cur in (select last_name || ' ' || first_name fio,
                     job, 
                     phone, 
                     mobile
                from client_contacts
               where clnt_clnt_id = pClntId)
  loop
     pipe row(cur);
  end loop;
  return;               
end;

--*********************************************************************************************************************  


-- ������� ������ ������ � ����������� ������������� � �� ������� ������ �� 4.2.1
--********************************************************************************************************************* 
function GetCompanyDolg(pClntId clients_dic.clnt_id%type) return tbl_sum pipelined parallel_enable is                      
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

--*********************************************************************************************************************
    

----------------------------------------------------------------------------------------------------
---- ������ � �����������
function fn_orders_doc_depricated(pID documents.dcmt_id%type,
                       pClntId clients_dic.clnt_id%type) return tbl_docs pipelined parallel_enable  is
begin
   for cur in (select d.dcmt_id id,       -- ������������� ���������
                      dl.ord_ord_id order_id,   -- ������������� ������
                      d.dctp_dctp_id type_id,  -- ��� ���������
                      dt.def name_doc,          -- ������������ ���� ���������
                      d.doc_date date_doc,      -- ���� ���������
                      d.navi_date uploaded_at,     -- ���� ��������
                      d.navi_user owner      -- �������� ��������� (��� ��������)
                from documents d, doc_links dl, doc_types dt,t_orders o, clrq_orders clrq, client_requests cl
                where d.dcmt_id = pId and
                      d.doc_state = 0 and  -- ������ ��������� ������ ��������� ��� ��������
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

-- �.�. 26.06.2017
function fn_orders_docs_depricated(
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
  v_rec t_doc;
begin
  v_sql := '
              select id, order_id, type_id, doc_type, doc_date, uploaded_at, owner
              from
              (
              select rownum rn, id, order_id, type_id, doc_type, doc_date, uploaded_at, owner
              from
              (
               select d.dcmt_id id,
                      dl.ord_ord_id order_id,
                      d.dctp_dctp_id type_id,
                      dt.def doc_type,
                      d.doc_date doc_date,
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
end fn_orders_docs_depricated;                                                                           
                                                                        

--*********************************************************************************************************************
  -- �������(�) ��� ������� � ��������
--*********************************************************************************************************************

-- ����� � ������� �.4.14.1 � �� �� ���������� ��� (�������� report_order)
-- �.�. 22.03.2017
function ReportOrder( pClntId clients_dic.clnt_id%type  -- ID �������
                    , pQuant  varchar2                  -- ����� ����������� ����������� {'year'|'month'|'week'|'day'}
                    , pStart  date                      -- ������ ��������� �������
                    , pStop   date                      -- ����� ��������� �������
                    ) return tbl_da3num                 -- ���� � 3 �����
                    pipelined
is
  is_Quant_OK number default 0;
begin
  -- �������� ������������ ������ �����������:
  select decode(pQuant, 'year',1, 'month',1, 'week',1, 'day',1, 0) into is_Quant_OK from dual;
  if is_Quant_OK = 0 then return; end if;
  -- ��������� �����:
  execute immediate 'alter session set nls_territory = ''russia'''; -- ���� ������ ���������� � ������������
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
  -- ���������� � ������������ (contractor)
--*********************************************************************************************************************

-- ������ � ����������� �.4.3.1 � �� �� ���������� ��� (�������� contractors_get)
-- �.�. 14.04.2017
function ContractorsGet(  pClntId       clients.clnt_id%type                    -- ID �������
                        , pAddressType  number    default null                  -- ��������, ������� � �.�. �� ������������.
                        , pPersonFor    varchar2  default null                  -- �� ��� ��������. �� ������������.
                        ) return        t_contractor
is
  cont_rec    t_contractor;
  contact_id  client_contacts.clcn_id%type;                                     -- ������ ����� ���� ������� - ��� ID.
begin
  begin
    select max(clcn_id) into contact_id 
    from client_contacts
    where clnt_clnt_id = pClntId;                                               -- ����� ����� ��������� �������.
  exception when no_data_found then                                             -- ��� ��������� � ������� client_contacts_dic:
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
exception when no_data_found then                                               -- ������ ������ ���:
  select 
      pClntId
    , null, null, null, null, null, null, null, null, null, null, null 
    into cont_rec from dual;
  return cont_rec;
end ContractorsGet;


-- ��������� ������������ �.4.3.2 � �� �� ���������� ��� (�������� contractors)
-- �.�. 17.04.2017
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
                      p_id_key      clients.clnt_id%type      default null      -- ���� ������ �� ID �����������
                    , p_id_opr      varchar2                  default '='       -- �������� ������ �� ID {'>' | '<' | '='}
                    , p_type_key    clients.cltp_cltp_id%type default null      -- ���� _�������_ (�����) �� ���� �����������
                    , p_name_key    clients.client_name%type  default null      -- ���� ������ �� ������������ �����������
                    , p_name_opr    varchar2                  default 'like'    -- �������� ������ �� ����� (like - � ��� �.�. ���?)
                    , p_limit       number                    default 10
                    , p_offset      number                    default 0
                    ) 
                    return          tbl_contractor_short      pipelined
is
  p_sort_line varchar2(100) default 'client_name';                              -- ORDER BY p_sort_line
  is_ok number := 0;                                                            -- ��� �������� ������� ���������� ����������
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

-- ����� ��������. �������� �.4.4.2 � �� �� ���������� ��� (�������� delivery_points_get)
-- �.�. 18.04.2017
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
    --and address_source is not null -- ��� �������
    --and zip is not null -- ��� �������
    and lp.ldpl_id = p_id;
  return v_rec;
exception when no_data_found then return v_rec;
end DeliveryPointsGet;

-- ����� ��������. ��������� ��������� �.4.4.5 � �� �� ���������� ��� (�������� delivery_points)
-- �.�. 20.04.2017
function delivery_points(
            p_id_key      t_loading_places.ldpl_id%type         default null    -- ���� ������ �� ID ����� ��������
          , p_id_opr      varchar2                              default '='     -- �������� ������ �� ID {'>' | '<' | '='}
          , p_name_key    client_contacts.name%type             default '%'     -- ���� ������ �� ����� � ����� ��������
          , p_name_opr    varchar2                              default 'like'  -- �������� ������ �� ����� (like - � ��� �.�. ���?)
          , p_addr_key    t_loading_places.address_source%type  default '%'     -- ���� ������ �� ������ ����� ��������
          , p_addr_opr    varchar2                              default 'like'  -- �������� ������ �� ������ (like - � ��� �.�. ���?)
          , p_phone_key   client_contacts.phone%type            default '%'     -- ���� ������ �� �������� � ����� ��������
          , p_phone_opr   varchar2                              default 'like'  -- �������� ������ �� �������� (like - � ��� �.�. ���?)
          , p_email_key   client_contacts.email%type            default '%'     -- ���� ������ �� �������� � ����� ��������
          , p_email_opr   varchar2                              default 'like'  -- �������� ������ �� �������� (like - � ��� �.�. ���?)
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

-- �������������. ��������� ���������. �. 4.10.1 � �� �� ���������� ��� (�������� debts)
-- �.�. 24.04.2017
function Debts(
                p_id          number                                            -- ID �������
              , p_limit       number                                            -- ����� ������������ �����
              , p_start_with  number  default 1                                 -- ����� ������ ������������ ������
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


                   
 
-- ��������� ������������. ��������� ���������. �. 4.3.1.1 � �� �� ���������� ���
--  ������ ���������� ��� �����������     
                
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
-- ���������� ����������� ������������� �� ������� �� �������� ����
-- ============================================================
-- ����������: SBCFinance
-- ����������: ���������� ����������� ������������� �� ������� �� �������� ����
-- ���������:  pStartDate - ���� ������ �������
--             pClntId - ��� �������
--             pHoldId - �������
--             pDate   - ����
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
    from -- ������� ����������� ������������� �� ������
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
 
-- ���������� ����������� ������������� ����������� �� ������� ���� � ������� �����
function GetClientDebetDolgEx(
   p_clnt_id in clients.clnt_id%type        -- ��� �����������
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

--===================================================================================
-- ���� �������� ���������� �� ������
-- 24.11.17  �. ���������
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
       return '��� ����������';
   when others then
       return '';        
end;        

--=======================================================================================
-- 27.11.17 �. ���������
-- ������ �� ������, ������ � ����� ����������� ������
-- �������� �� ������� ����������� (���������) �� ������
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
     -- ��� ����������� (���������) �� ������ � ���� ������          
    return null; 
end;  

--- 02.02.2018 ������� ������ ���������� ���������� �� ������
function GetOrder_receivables (pOrdId in t_orders.ord_id%type,
                               pValueType in number) return number is
receivables number(15,2);  
vSummaOrder number(15,2);
vSummaOplacheno number(15,2);
begin 
     -- ����� ����������� �������� �� ������       
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
     -- ������ ������������� �� ������
     -- ����� � ������ �� ������
     select nvl(sum(round(id.price*id.quantity/i.base_rate, 2)),0)
       into vSummaOrder
       from invoice_details id,invoices i 
      where id.ord_ord_id   = pOrdId and 
            id.invc_invc_id = i.invc_id and 
            i.intp_intp_id  = 1 and 
            i.del_user is Null;
     receivables := vSummaOrder - vSummaOplacheno;
  else
    -- ������ ���������� �� ����� ����������� �������� �� ������  
     receivables := vSummaOplacheno;     
  end if;          
  return  receivables;
end;

function Test return tblTest
  pipelined
  parallel_enable is
  lCursor sys_refcursor;
  lRow    tTest;
  lTestNum number := 1075567;
  lTestNum1 number := 1075568;
begin

  OPEN lCursor FOR 'select mcsf_api.GetOrder_receivables(t.ord_id,1) id -- ������� �������
  from orders t 
  where t.ord_id in (:lTestNum, :lTestNum1)' using lTestNum, lTestNum1;

  LOOP
    FETCH lCursor
      INTO lRow;
    EXIT WHEN lCursor%NOTFOUND;
    PIPE ROW(lRow);
  END LOOP;

  CLOSE lCursor;
  return;
end;
                                   
end MCSF_API;

 
/
