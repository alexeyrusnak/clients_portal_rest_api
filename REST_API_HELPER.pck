create or replace package REST_API_HELPER is

  /*
  ֲûגמהטע מבתוךע T_DOC ג JSON
  */
  procedure PrintT_DOC(pDoc in sbc.T_DOC);

  /*
  ֲûגמהטע מבתוךע T_UNIT ג JSON
  */
  procedure PrintT_UNIT(pUnit in sbc.T_UNIT);

  /*
  ֲûגמהטע מבתוךע T_POINT ג JSON
  */
  procedure PrintT_POINT(pPoint in sbc.T_POINT);

  /*
  ֲûגמהטע מבתוךע T_CARGO ג JSON
  */
  procedure PrintT_CARGO(pCargo in sbc.T_CARGO);

end REST_API_HELPER;
/
create or replace package body REST_API_HELPER is

  /*
  ֲûגמהטע מבתוךע T_DOC ג JSON
  */
  procedure PrintT_DOC(pDoc in sbc.T_DOC) is
  begin
    apex_json.write('id', pDoc.id);
    apex_json.write('name', pDoc.name);
    apex_json.write('url', pDoc.url);
    apex_json.write('ext', pDoc.ext);
    apex_json.write('size_doc', pDoc.size_doc);
    apex_json.write('date_doc',
                    to_char(pDoc.date_doc, REST_API.PkgDefaultDateFormat));
    apex_json.write('uploaded_at',
                    to_char(pDoc.uploaded_at, REST_API.PkgDefaultDateFormat));
    apex_json.write('owner', pDoc.owner);
  end;

  /*
  ֲûגמהטע מבתוךע T_UNIT ג JSON
  */
  procedure PrintT_UNIT(pUnit in sbc.T_UNIT) is
  begin
    apex_json.write('type_unit', pUnit.type_unit);
    apex_json.write('transport', pUnit.transport);
    apex_json.write('comment_unit', pUnit.comment_unit);
    apex_json.write('conditions', pUnit.conditions);
    apex_json.write('notes', pUnit.notes);
    apex_json.write('is_insurance', pUnit.is_insurance);
  
    -- cargoes[]
    apex_json.open_array('payload');
  
    for elem in 1 .. pUnit.payload.count loop
      apex_json.open_object;
      PrintT_CARGO(pUnit.payload(elem));
      apex_json.close_object;
    end loop;
  
    apex_json.close_array;
  
    apex_json.write('delivery_point', pUnit.delivery_point);
  end;

  /*
  ֲûגמהטע מבתוךע T_POINT ג JSON
  */
  procedure PrintT_POINT(pPoint in sbc.T_POINT) is
  begin
    apex_json.write('id', pPoint.id);
    apex_json.write('address', pPoint.address);
    apex_json.write('phone', pPoint.phone);
    apex_json.write('email', pPoint.email);
    apex_json.write('name', pPoint.name);
    apex_json.write('unit_count', pPoint.unit_count);
  end;

  /*
  ֲûגמהטע מבתוךע T_CARGO ג JSON
  */
  procedure PrintT_CARGO(pCargo in sbc.T_CARGO) is
  begin
  
    apex_json.write('name', pCargo.name);
    apex_json.write('brutto', pCargo.brutto);
    apex_json.write('netto', pCargo.netto);
    apex_json.write('cost_cargo', pCargo.cost_cargo);
    apex_json.write('currency_code', pCargo.currency_code);
    apex_json.write('volume', pCargo.volume);
    apex_json.write('hazard_class', pCargo.hazard_class);
    apex_json.write('temperature', pCargo.temperature);
    apex_json.write('places_count', pCargo.places_count);
    apex_json.write('size_cargo', pCargo.size_cargo);
    apex_json.write('made', pCargo.made);
    apex_json.write('nareadinessme',
                    to_char(pCargo.readiness, REST_API.PkgDefaultDateFormat));
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
