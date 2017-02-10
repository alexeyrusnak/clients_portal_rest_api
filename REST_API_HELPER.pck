create or replace package REST_API_HELPER is

  /*
  ֲûגמהטע מבתוךע T_DOC ג JSON
  */
  procedure PrintT_DOC(pDoc in T_DOC);

  /*
  ֲûגמהטע מבתוךע T_DOCS ג JSON
  */
  procedure PrintT_DOCS(pDoc in mcsf_api.t_docs);

  /*
  ֲûגמהטע מבתוךע T_UNIT ג JSON
  */
  procedure PrintT_UNIT(pUnit in T_UNIT);

  /*
  ֲûגמהטע מבתוךע T_POINT ג JSON
  */
  procedure PrintT_POINT(pPoint in T_POINT);

  /*
  ֲûגמהטע מבתוךע T_CARGO ג JSON
  */
  procedure PrintT_CARGO(pCargo in T_CARGO);

end REST_API_HELPER;
/
create or replace package body REST_API_HELPER is

  /*
  ֲûגמהטע מבתוךע T_DOC ג JSON
  */
  procedure PrintT_DOC(pDoc in T_DOC) is
  begin
    apex_json.write('id', pDoc.id, true);
    apex_json.write('name', pDoc.name, true);
    apex_json.write('url', pDoc.url, true);
    apex_json.write('ext', pDoc.ext, true);
    apex_json.write('size_doc', pDoc.size_doc, true);
    apex_json.write('date_doc',
                    to_char(pDoc.date_doc, REST_API.PkgDefaultDateFormat),
                    true);
    apex_json.write('uploaded_at',
                    to_char(pDoc.uploaded_at, REST_API.PkgDefaultDateFormat),
                    true);
    apex_json.write('owner', pDoc.owner, true);
  end;

  /*
  ֲûגמהטע מבתוךע T_DOCS ג JSON
  */
  procedure PrintT_DOCS(pDoc in mcsf_api.t_docs) is
  begin
    apex_json.write('id', pDoc.id, true);
    apex_json.write('order_id', pDoc.order_id, true);
    apex_json.write('type', pDoc.type_doc, true);
    apex_json.write('name', pDoc.name_doc, true);
    apex_json.write('date_doc',
                    to_char(pDoc.date_doc, REST_API.PkgDefaultDateFormat),
                    true);
    apex_json.write('uploaded_at',
                    to_char(pDoc.uploaded_at, REST_API.PkgDefaultDateFormat),
                    true);
    apex_json.write('owner', pDoc.owner, true);
  end;

  /*
  ֲûגמהטע מבתוךע T_UNIT ג JSON
  */
  procedure PrintT_UNIT(pUnit in T_UNIT) is
  begin
    apex_json.write('type_unit', pUnit.type_unit, true);
    apex_json.write('transport', pUnit.transport, true);
    apex_json.write('comment_unit', pUnit.comment_unit, true);
    apex_json.write('conditions', pUnit.conditions, true);
    apex_json.write('notes', pUnit.notes, true);
    apex_json.write('is_insurance', pUnit.is_insurance, true);
  
    -- cargoes[]
    apex_json.open_array('payload');
  
    for elem in 1 .. pUnit.payload.count loop
      apex_json.open_object;
      PrintT_CARGO(pUnit.payload(elem));
      apex_json.close_object;
    end loop;
  
    apex_json.close_array;
  
    apex_json.write('delivery_point', pUnit.delivery_point, true);
  end;

  /*
  ֲûגמהטע מבתוךע T_POINT ג JSON
  */
  procedure PrintT_POINT(pPoint in T_POINT) is
  begin
    apex_json.write('id', pPoint.id, true);
    apex_json.write('address', pPoint.address, true);
    apex_json.write('phone', pPoint.phone, true);
    apex_json.write('email', pPoint.email, true);
    apex_json.write('name', pPoint.name, true);
    apex_json.write('unit_count', pPoint.unit_count, true);
  end;

  /*
  ֲûגמהטע מבתוךע T_CARGO ג JSON
  */
  procedure PrintT_CARGO(pCargo in T_CARGO) is
  begin
  
    apex_json.write('name', pCargo.name, true);
    apex_json.write('brutto', pCargo.brutto, true);
    apex_json.write('netto', pCargo.netto, true);
    apex_json.write('cost_cargo', pCargo.cost_cargo, true);
    apex_json.write('currency_code', pCargo.currency_code, true);
    apex_json.write('volume', pCargo.volume, true);
    --   apex_json.write('hazard_class', pCargo.hazard_class, true);
    --   apex_json.write('temperature', pCargo.temperature, true);
    --   apex_json.write('places_count', pCargo.places_count, true);
    apex_json.write('size_cargo', pCargo.size_cargo, true);
    --   apex_json.write('made', pCargo.made);
    apex_json.write('nareadinessme',
                    to_char(pCargo.readiness, REST_API.PkgDefaultDateFormat),
                    true);
    apex_json.write('ref_ord', pCargo.ref_ord);
  
    -- cargo delivery point
    apex_json.open_object('delivery_point');
  
    for elem in 1 .. pCargo.delivery_point.count loop
      PrintT_POINT(pCargo.delivery_point(elem));
    end loop;
  
    apex_json.close_object;
  
  end;

end REST_API_HELPER;
/
