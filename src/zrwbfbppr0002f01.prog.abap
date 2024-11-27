*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0002F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form PICKING_TASK_CREATE
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM picking_task_create.

  alv_grid_transport->get_selected_rows( IMPORTING et_index_rows = DATA(rows) ).

  IF rows IS INITIAL.
    MESSAGE s035(zrwbfbpmc0001) DISPLAY LIKE 'W'. "Nenhuma linha selecionada, tente novamente!
    RETURN.
  ENDIF.

  LOOP AT rows INTO DATA(row).

    TRY.
        DATA(shipment_request_data) = output_transport[ row-index ].

        CHECK shipment_request_data-picking_task IS INITIAL.
        APPEND shipment_request_data TO picking_task_data-delivery_data.

      CATCH cx_sy_itab_line_not_found.
        CLEAR: shipment_request_data.
    ENDTRY.

  ENDLOOP.

  LOOP AT picking_task_data-delivery_data ASSIGNING FIELD-SYMBOL(<delivery>).
    <delivery>-id = screen_fields-id.
  ENDLOOP.

  DATA(return) = NEW zrwbfbpcl_picking_task_create( picking_task_data )->create(  ).

  CLEAR: picking_task_data.

  PERFORM refresh_from_db.
  PERFORM display_messages USING return.

  alv_grid_transport->refresh_table_display( ).

ENDFORM.


*&---------------------------------------------------------------------*
*& Form PICKING_TASK_RESTART
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM picking_task_restart.

  alv_grid->get_selected_rows( IMPORTING et_index_rows = DATA(rows) ).

  IF rows IS INITIAL.
    MESSAGE s035(zrwbfbpmc0001) DISPLAY LIKE 'W'. "Nenhuma linha selecionada, tente novamente!
    RETURN.
  ENDIF.

  LOOP AT rows INTO DATA(row).

    TRY.
        DATA(shipment_request_data) = output_transport[ row-index ].
      CATCH cx_sy_itab_line_not_found.
        CLEAR: shipment_request_data.
    ENDTRY.

    LOOP AT output_transport INTO DATA(transport) WHERE picking_task = shipment_request_data-picking_task.
      APPEND transport TO picking_task_data-delivery_data.
    ENDLOOP.

  ENDLOOP.

  DATA(return) = NEW zrwbfbpcl_picking_task_restart( picking_task_data )->restart(  ).

  CLEAR: picking_task_data.

  PERFORM refresh_from_db.
  PERFORM display_messages USING return.

  alv_grid->refresh_table_display( ).

ENDFORM.


*&---------------------------------------------------------------------*
*& Form REFRESH_FROM_DB
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_from_db.

  CLEAR: output_transport.
  DATA: shipment_request_data TYPE zrwbfbps0003.

  DATA(return) = NEW zrwbfbpcl_get_shipment_request( screen_fields-id )->get( IMPORTING shipment_request_data = shipment_request_data ).

  screen_fields = CORRESPONDING #( shipment_request_data-customer_data ).
  output_transport = shipment_request_data-delivery_data.

  PERFORM display_messages USING return.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form GET_PICKING_TASK_HISTORIC
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_picking_task_historic.

  alv_grid->get_selected_rows( IMPORTING et_index_rows = DATA(rows) ).

  IF rows IS INITIAL.
    MESSAGE s035(zrwbfbpmc0001) DISPLAY LIKE 'W'. "Nenhuma linha selecionada, tente novamente!
    RETURN.
  ENDIF.

  TRY.
      line = output_transport[ rows[ 1 ]-index ].
    CATCH cx_sy_itab_line_not_found.
      CLEAR:line.
  ENDTRY.

  IF line-version = 0.
    MESSAGE s047(zrwbfbpmc0001) DISPLAY LIKE 'W' WITH line-picking_task. "Não há histórico de versões para a tarefa de separação &.
    RETURN.
  ENDIF.

  output_historic = NEW zrwbfbpcl_picking_task_hist( line )->get(  ).

  CALL SCREEN 9009 STARTING AT 50 5
                     ENDING AT 113 17.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form SHIPMENT_REQUEST_MONITOR
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM shipment_request_monitor .

  DATA: shipment_request_monitor TYPE zrwbfbps0003,
        customer                 TYPE kunnr.

  PERFORM call_popup_customer CHANGING customer.

  IF customer IS INITIAL.
    LEAVE TO SCREEN 9001.
  ENDIF.

  DATA(return) = NEW zrwbfbpcl_shipment_req_monitor( customer )->get( IMPORTING shipment_request_monitor = shipment_request_monitor  ).
  NEW zrwbfbpcl_delete_duplicates( screen_fields-id )->change( CHANGING delivery_data = shipment_request_monitor ).

  screen_fields = CORRESPONDING #( shipment_request_monitor-customer_data ).
  output_item = shipment_request_monitor-delivery_data.

  PERFORM display_messages USING return.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form CALL_POPUP_CUSTOMER
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_popup_customer CHANGING customer.

  DATA: return     TYPE bapiret1,
        fields     TYPE ty_sval,
        returncode TYPE bapiret1.

  fields = VALUE ty_sval( ( tabname    = 'KNA1'
                            fieldname  = 'KUNNR'
                            fieldtext  = 'Cliente'
                            field_obl  = abap_true ) ).

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      no_value_check  = space
      popup_title     = 'Selecione o Cliente'
    IMPORTING
      returncode      = returncode
    TABLES
      fields          = fields
    EXCEPTIONS
      error_in_fields = 1
      OTHERS          = 2.

  TRY.
      customer = fields[ fieldname = 'KUNNR' ]-value.
    CATCH cx_sy_itab_line_not_found.
      CLEAR customer.
  ENDTRY.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form CALL_POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_popup_to_confirm.

  DATA answer(1).

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Encerrar mod.'
      text_question         = TEXT-001
      text_button_1         = 'Sim'
      text_button_2         = 'Não'
      display_cancel_button = abap_true
      popup_type            = 'ICON_MESSAGE_QUESTION'
    IMPORTING
      answer                = answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

  IF answer = 'A' OR answer = '2' .

    IF screen_fields-status = 'PL'.
      control_screen = 'MODIFY'.
      control_alv = 9008.
    ELSE.
      control_screen = 'MODIFY'.
      control_alv = 9007.
    ENDIF.

    LEAVE TO SCREEN 9002.

  ELSE.
    control_screen = 'SAVE'.
    control_alv = 9007.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form MODIFY_SHIPMENT_REQUEST
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_shipment_request .

  DATA:shipment_request_monitor TYPE zrwbfbps0003.
  DATA(return) = NEW zrwbfbpcl_shipment_req_monitor( screen_fields-customer )->get( IMPORTING shipment_request_monitor = shipment_request_monitor ).

  NEW zrwbfbpcl_delete_duplicates( screen_fields-id )->change( CHANGING delivery_data = shipment_request_monitor ).

  output_item = shipment_request_monitor-delivery_data.

  PERFORM display_messages USING return.

  IF return-type = 'E'.
    LEAVE TO SCREEN 9001.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form CHECK_EDITING_ALLOWED
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_editing_allowed.

  SELECT SINGLE * FROM zrwbfbpt0001 INTO @DATA(shipment_request) WHERE id = @screen_fields-id.

  IF shipment_request-status = 'CH' OR
     shipment_request-status = 'CO'.

    DATA(status) = shipment_request-status_description.
    TRANSLATE status TO UPPER CASE.

    DATA(return) = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                      type   = 'E'
                                                      number = '010'
                                                      var1   = CONV #( status ) ) . "Status & não permite alteração!

    PERFORM display_messages USING return.
    LEAVE TO SCREEN 9001.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form CREATE_SHIPMENT_REQUEST
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_shipment_request .

  CLEAR: shipment_request_data-delivery_data.

  shipment_request_data-delivery_data = output_transport.
  shipment_request_data-customer_data = CORRESPONDING #( screen_fields ).

  DATA(return) = NEW zrwbfbpcl_shipment_req_create( shipment_request_data )->create( IMPORTING shipment_request_id = screen_fields-id ).

  IF return-type = 'E'.

    control_screen = 'CREATE'.
    control_alv    = '9008'.

    PERFORM display_messages USING return.

  ELSE.

    PERFORM refresh_from_db.
    PERFORM display_messages USING return.

    alv_grid_transport->refresh_table_display( ).

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form SAVE_SHIPMENT_REQUEST
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_shipment_request.

  CLEAR: shipment_request_data-delivery_data,
         output_item.

  shipment_request_data-delivery_data = output_transport.
  shipment_request_data-customer_data = CORRESPONDING #( screen_fields ).

  DATA(return) = NEW zrwbfbpcl_shipment_req_save( shipment_request_data )->save(   ).

  PERFORM display_messages USING return.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form GET_SHIPMENT_REQUEST
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_shipment_request .

  DATA: shipment_request_data TYPE zrwbfbps0003.
  DATA(return) = NEW zrwbfbpcl_get_shipment_request( screen_fields-id )->get( IMPORTING shipment_request_data = shipment_request_data ).

  PERFORM display_messages USING return.

  IF return-type = 'E'.
    LEAVE TO SCREEN 9001.
  ENDIF.

  screen_fields = CORRESPONDING #( shipment_request_data-customer_data ).
  output_transport = shipment_request_data-delivery_data.

  CHECK control_screen = 'MODIFY'.

  IF screen_fields-status = 'PL'.
    control_alv = '9008'.
  ELSE.
    control_alv = '9007'.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form DELETE_SHIPMENT_REQUEST
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_shipment_request .

  DATA(return) = NEW zrwbfbpcl_shipment_req_delete( screen_fields-id )->delete(  ).

  PERFORM display_messages USING return.

  IF return-type = 'E'.
    LEAVE TO SCREEN 9001.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form SEND_SELECTED_ROW
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM send_selected_row .

  alv_grid_item->get_selected_rows( IMPORTING et_index_rows = DATA(rows) ).

  IF rows IS INITIAL.
    MESSAGE s035(zrwbfbpmc0001) DISPLAY LIKE 'W'. "Nenhuma linha selecionada, tente novamente!
    RETURN.
  ENDIF.

  CLEAR: selected_data.
  LOOP AT rows INTO DATA(row).

    TRY.
        DATA(alv_row) = output_item[ row-index ].
        APPEND alv_row TO selected_data.
      CATCH cx_sy_itab_line_not_found.
        CLEAR: alv_row.
    ENDTRY.

  ENDLOOP.

  NEW zrwbfbpcl_container_next( selected_data )->next( CHANGING deliveries = output_transport
                                                                item_data  = output_item ).

  PERFORM save_delivery.
  PERFORM refresh.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form RETURN_SELECTED_ROW
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM return_selected_row .

  alv_grid_transport->get_selected_rows( IMPORTING et_index_rows = DATA(rows) ).

  IF rows IS INITIAL.
    MESSAGE s035(zrwbfbpmc0001) DISPLAY LIKE 'W'. "Nenhuma linha selecionada, tente novamente!
    RETURN.
  ENDIF.

  CLEAR: selected_data.
  LOOP AT rows INTO DATA(row).

    TRY.
        DATA(alv_row) = output_transport[ row-index ].
        APPEND alv_row TO selected_data.
      CATCH cx_sy_itab_line_not_found.
        CLEAR: alv_row.
    ENDTRY.

  ENDLOOP.

  NEW zrwbfbpcl_container_return( selected_data )->return( CHANGING deliveries = output_transport
                                                                    item_data  = output_item ).

  PERFORM refresh.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form UPDATE_STATUS_SEPARATE
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_status_separate.

  DATA(update_from_data) = VALUE zrwbfbps0013( shipment_request      = screen_fields-id
                                               shipment_request_item = output_transport
                                               status                = 'SE'
                                               status_description    = 'Separação' ).

  DATA(return) = NEW zrwbfbpcl_ship_req_upd_status( update_from_data )->update(  ).

  IF return-type = 'S'.
    control_alv = '9007'.
  ENDIF.

  PERFORM refresh_from_db.
  PERFORM display_messages USING return.

  alv_grid_transport->refresh_table_display( ).

ENDFORM.


*&---------------------------------------------------------------------*
*& Form UPDATE_STATUS_CHECKOUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_status_checkout .

  DATA(update_from_data) = VALUE zrwbfbps0013( shipment_request      = screen_fields-id
                                               shipment_request_item = output_transport
                                               status                = 'CH'
                                               status_description    = 'Checkout' ).

  DATA(return) = NEW zrwbfbpcl_ship_req_upd_status( update_from_data )->update(  ).

  IF return-type = 'S'.
    control_alv = '9007'.
  ENDIF.

  PERFORM refresh_from_db.
  PERFORM display_messages USING return.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form UPDATE_STATUS_CANCEL
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_status_cancel .

  AUTHORITY-CHECK OBJECT 'ZUSER_CHEC'
                      ID 'ACTVT' FIELD '23'.

  IF sy-subrc = 0.

    DATA(update_from_data) = VALUE zrwbfbps0013( shipment_request   = screen_fields-id
                                                 status             = 'CA'
                                                 status_description = 'Cancelado' ).

    DATA(return) = NEW zrwbfbpcl_ship_req_upd_status( update_from_data )->update(  ).

    PERFORM display_messages USING return.
    LEAVE TO SCREEN 9001.

  ELSE.

    MESSAGE s033(zrwbfbpmc0001) DISPLAY LIKE 'E' WITH sy-uname. "Função não autorizada ao usuário & .
    RETURN.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form SAVE_DELIVERY
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_delivery.

  CHECK screen_fields-id IS NOT INITIAL.

  LOOP AT output_transport INTO DATA(delivery).

    DATA(delivery_save) = VALUE zrwbfbpt0002( id                   = screen_fields-id
                                              picking_task         = delivery-picking_task
                                              delivery             = delivery-delivery
                                              item                 = delivery-item
                                              material             = delivery-material
                                              material_description = delivery-material_description
                                              material_quantity    = delivery-material_quantity
                                              unit_measurement     = delivery-unit_measurement
                                              gross_weight         = delivery-gross_weight
                                              unit_weight          = delivery-unit_weight ).

    MODIFY zrwbfbpt0002 FROM delivery_save.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form CLEAR_OUTPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear_output.

  CLEAR: ok_code,
         output_transport,
         output_item.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form SET_SUBSCREEN
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_subscreen USING set_active    TYPE char10
                         set_container TYPE char10
                         set_subscreen TYPE syst_dynnr .

  container-activetab = set_active.
  container           = set_container.
  control_subscreen   = set_subscreen.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form GET_DESCRIPTION_FIELD_MONITOR
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_description_field_monitor .

  IF control_screen = 'CREATE' OR
     control_screen = 'UPDATE' OR
     control_screen = 'MODIFY' OR
     control_screen = 'NEXT'   OR
     control_screen = 'RETURN' OR
     control_screen = 'CREATE_TASK'.

    DATA(retrieve_description) = NEW zrwbfbpcl_get_descr_field( screen_fields ).

    screen_fields-status_description         = retrieve_description->retrieve_status( ).
    screen_fields-plant_description          = retrieve_description->retrieve_plant( ).
    screen_fields-transport_type_description = retrieve_description->retrieve_transport_type( ).
    screen_fields-shipping_company           = retrieve_description->retrieve_shipping_company( ).
    screen_fields-vehicle_type_description   = retrieve_description->retrieve_vehicle_type( ).

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form PRINT_SHIPMENT_REQUEST_LABEL
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM print_shipment_request_label.

  NEW zrwbfbpcl_shipment_req_print( screen_fields-id )->call_print(  ).

ENDFORM.


*&---------------------------------------------------------------------*
*& Form REFRESH
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh.

  alv_grid_transport->refresh_table_display( ).
  alv_grid_item->refresh_table_display( ).

ENDFORM.


*&---------------------------------------------------------------------*
*& Form DISPLAY_MESSAGES
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_messages USING return TYPE bapiret2.

  CHECK return IS NOT INITIAL.

  MESSAGE ID return-id TYPE 'S' NUMBER return-number WITH return-message_v1
                                                          return-message_v2
                                                          return-message_v3
                                                          return-message_v4 DISPLAY LIKE return-type.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form  CREATE_FIELDCATALOG
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
* Create a field catalogue from any internal table
*----------------------------------------------------------------------*
*      -->PT_TABLE     Internal table
*      -->PT_FIELDCAT  Field Catalogue
*----------------------------------------------------------------------*
FORM create_fieldcatalog.

  IF  control_screen = 'DISPLAY'   OR
      control_screen = 'SAVE'      OR
      control_screen = 'CREATE_DB' OR
    ( control_screen = 'MODIFY'    AND
      screen_fields-status <> 'PL' ).

    fieldcat_transport = VALUE lvc_t_fcat( ( col_pos = 1  fieldname = 'DELIVERY'             coltext = 'Remessa'               outputlen = 10 key = abap_true    )
                                           ( col_pos = 2  fieldname = 'ITEM'                 coltext = 'Item'                  outputlen = 6  key = abap_true    )
                                           ( col_pos = 3  fieldname = 'PICKING_TASK'         coltext = 'Tarefa de separação'   outputlen = 15                    )
                                           ( col_pos = 4  fieldname = 'VERSION'              coltext = 'Versão'                outputlen = 6                     )
                                           ( col_pos = 5  fieldname = 'ICON'                 coltext = 'S' just = 'C'          outputlen = 3                     )
                                           ( col_pos = 6  fieldname = 'STATUS_DESCRIPTION'   coltext = 'Status'                outputlen = 20                    )
                                           ( col_pos = 7  fieldname = 'MATERIAL'             coltext = 'Material'              outputlen = 20                    )
                                           ( col_pos = 8  fieldname = 'MATERIAL_DESCRIPTION' coltext = 'Descrição do material' outputlen = 29                    )
                                           ( col_pos = 9  fieldname = 'MATERIAL_QUANTITY'    coltext = 'Quantidade'            outputlen = 15                    )
                                           ( col_pos = 10 fieldname = 'UNIT_MEASUREMENT'     coltext = 'UMB'                   outputlen = 4                     )
                                           ( col_pos = 11 fieldname = 'QUANTITY'             coltext = 'Quantidade separada'   outputlen = 15                    )
                                           ( col_pos = 12 fieldname = 'UNIT'                 coltext = 'UMB'                   outputlen = 4                     )
                                           ( col_pos = 13 fieldname = 'GROSS_WEIGHT'         coltext = 'Peso bruto separado'   outputlen = 18 do_sum = abap_true )
                                           ( col_pos = 14 fieldname = 'UNIT_WEIGHT'          coltext = 'Un.'                   outputlen = 4                     )
                                           ( col_pos = 15 fieldname = 'USER_RESPONSIBLE'     coltext = 'Usuario responsavel'   outputlen = 20                    ) ).

  ELSEIF screen_fields-status = 'PL'      AND
       ( control_screen       = 'MODIFY'  OR
         control_screen       = 'CREATE' ).

    fieldcat_transport = VALUE lvc_t_fcat( ( col_pos = 1  fieldname = 'DELIVERY'             coltext = 'Remessa'               outputlen = 10 key = abap_true    )
                                           ( col_pos = 2  fieldname = 'ITEM'                 coltext = 'Item'                  outputlen = 6  key = abap_true    )
                                           ( col_pos = 3  fieldname = 'PICKING_TASK'         coltext = 'Tarefa de separação'   outputlen = 15                    )
                                           ( col_pos = 4  fieldname = 'MATERIAL'             coltext = 'Material'              outputlen = 15                    )
                                           ( col_pos = 5  fieldname = 'MATERIAL_DESCRIPTION' coltext = 'Descrição do material' outputlen = 30                    )
                                           ( col_pos = 6  fieldname = 'MATERIAL_QUANTITY'    coltext = 'Quantidade'            outputlen = 10                    )
                                           ( col_pos = 7  fieldname = 'UNIT_MEASUREMENT'     coltext = 'UMB'                   outputlen = 4                     )
                                           ( col_pos = 8  fieldname = 'QUANTITY'             coltext = 'Quantidade separada'   outputlen = 15                    )
                                           ( col_pos = 9  fieldname = 'UNIT'                 coltext = 'UMB'                   outputlen = 4                     )
                                           ( col_pos = 10 fieldname = 'GROSS_WEIGHT'         coltext = 'Peso bruto'            outputlen = 10 do_sum = abap_true )
                                           ( col_pos = 11 fieldname = 'UNIT_WEIGHT'          coltext = 'Un.'                   outputlen = 4                     )
                                           ( col_pos = 12 fieldname = 'USER_RESPONSIBLE'     coltext = 'Usuario responsavel'   outputlen = 20                    )
                                           ( col_pos = 13 fieldname = 'VERSION'              coltext = 'Versão'                outputlen = 6                     )
                                           ( col_pos = 14 fieldname = 'ICON'                 coltext = 'S' just = 'C'          outputlen = 3                     )
                                           ( col_pos = 15 fieldname = 'STATUS_DESCRIPTION'   coltext = 'Status'                outputlen = 20                    ) ).

    fieldcat_item = VALUE lvc_t_fcat( ( col_pos = 1 fieldname = 'DELIVERY'             coltext = 'Remessa'               outputlen = 10 key = abap_true )
                                      ( col_pos = 2 fieldname = 'ITEM'                 coltext = 'Item'                  outputlen = 6                  )
                                      ( col_pos = 3 fieldname = 'MATERIAL'             coltext = 'Material'              outputlen = 15                 )
                                      ( col_pos = 4 fieldname = 'MATERIAL_DESCRIPTION' coltext = 'Descrição do material' outputlen = 29                 )
                                      ( col_pos = 5 fieldname = 'MATERIAL_QUANTITY'    coltext = 'Quantidade'            outputlen = 10                 )
                                      ( col_pos = 6 fieldname = 'UNIT_MEASUREMENT'     coltext = 'UMB'                   outputlen = 3                  )
                                      ( col_pos = 7 fieldname = 'GROSS_WEIGHT'         coltext = 'Peso bruto'            outputlen = 11                 )
                                      ( col_pos = 8 fieldname = 'UNIT_WEIGHT'          coltext = 'Un.'                   outputlen = 3                  ) ).

  ENDIF.

  fieldcat_historic = VALUE lvc_t_fcat( ( col_pos = 1 fieldname = 'PICKING_TASK'      coltext = 'Tarefa de separação'  outputlen = 15 key = abap_true )
                                        ( col_pos = 2 fieldname = 'VERSION'           coltext = 'Versão'               outputlen = 6  key = abap_true )
                                        ( col_pos = 3 fieldname = 'SEPARATE_QUANTITY' coltext = 'Quantidade'           outputlen = 10                 )
                                        ( col_pos = 4 fieldname = 'UNIT_MEASUREMENT'  coltext = 'Un.'                  outputlen = 3                  )
                                        ( col_pos = 5 fieldname = 'QUANTITY_SEPARATE' coltext = 'Quantidade separada'  outputlen = 15                 )
                                        ( col_pos = 6 fieldname = 'UNIT'              coltext = 'Un.'                  outputlen = 3                  )
                                        ( col_pos = 7 fieldname = 'USER_RESPONSIBLE'  coltext = 'Usuario responsavel'  outputlen = 15                 ) ).

ENDFORM.
