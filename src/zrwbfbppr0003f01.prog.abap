*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0003F01
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

  alv_grid_item->get_selected_rows( IMPORTING et_index_rows = DATA(rows) ).

  IF rows IS INITIAL.
    MESSAGE s035(zrwbfbpmc0001) DISPLAY LIKE 'W'. "Nenhuma linha selecionada, tente novamente!
    RETURN.
  ENDIF.

  LOOP AT rows INTO DATA(row).

    TRY.
        DATA(shipment_request_data) = output_item[ row-index ].

        CHECK shipment_request_data-picking_task IS INITIAL.
        APPEND shipment_request_data TO shipment_request-delivery_data.

      CATCH cx_sy_itab_line_not_found.
        CLEAR: shipment_request_data.
    ENDTRY.

  ENDLOOP.

  DATA(return) = NEW zrwbfbpcl_picking_task_create( shipment_request )->create(  ).

  CLEAR: shipment_request.
  PERFORM display_messages USING return.
  PERFORM refresh_from_db.

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

  alv_grid_item->get_selected_rows( IMPORTING et_index_rows = DATA(rows) ).

  IF rows IS INITIAL.
    MESSAGE s035(zrwbfbpmc0001) DISPLAY LIKE 'W'. "Nenhuma linha selecionada, tente novamente!
    RETURN.
  ENDIF.

  CLEAR:shipment_request-delivery_data.

  LOOP AT rows INTO DATA(row).

    TRY.
        DATA(shipment_request_data) = output_item[ row-index ].
      CATCH cx_sy_itab_line_not_found.
        CLEAR: shipment_request_data.
    ENDTRY.

    LOOP AT output_item INTO DATA(delivery) WHERE picking_task = shipment_request_data-picking_task.
      APPEND delivery TO shipment_request-delivery_data.
    ENDLOOP.

  ENDLOOP.

  DATA(return) = NEW zrwbfbpcl_picking_task_restart( shipment_request )->restart(  ).

  CLEAR: shipment_request.
  PERFORM display_messages USING return.
  PERFORM refresh_from_db.

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

  DATA: shipment_request_data TYPE zrwbfbps0003.

  DATA(shipment_request) = VALUE #( output_item[ 1 ]-id OPTIONAL ).

  CLEAR: output_item,
         header_data,
         output_header.

  DATA(return) = NEW zrwbfbpcl_get_shipment_request( shipment_request )->get( IMPORTING shipment_request_data = shipment_request_data ).

  output_item = shipment_request_data-delivery_data.

  PERFORM get_data.
  PERFORM build.

  alv_grid_header->refresh_table_display( ).
  alv_grid_header->refresh_table_display( ).

  alv_grid_item->set_frontend_layout( is_layout = layout_item ).
  alv_grid_item->refresh_table_display( ).

ENDFORM.


*&---------------------------------------------------------------------*
*& Form DISPLAY_SHIPMENT_REQ_MONITOR
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_shipment_req_monitor.

  alv_grid_header->get_selected_rows( IMPORTING et_index_rows = DATA(rows) ).

  IF rows IS INITIAL.

    MESSAGE e026(zrwbfbpmc0001). "Selecione uma linha e tente novamente!
    RETURN.

  ENDIF.

  LOOP AT rows INTO DATA(row).

    TRY.
        DATA(shipment_request) = header_data[ row-index  ] .

        IF shipment_request-status = 'CA'.

          DATA(return) = VALUE bapiret2( type       = 'E'
                                         id         = 'ZRWBFBPMC0001'
                                         number     = 043 ).

          PERFORM display_messages USING return.
          RETURN.

        ENDIF.

        SET PARAMETER ID 'ZRWBFBP_CHECK' FIELD 'TRACKING'.
        SET PARAMETER ID 'ZRWBFBP_ID' FIELD shipment_request-id.

        CALL TRANSACTION 'ZRWBFBPTR0002' AND SKIP FIRST SCREEN.

      CATCH
        cx_sy_itab_line_not_found.
    ENDTRY .

    FREE MEMORY ID 'ZRWBFBP_CHECK'.
    FREE MEMORY ID 'ZRWBFBP_ID'.

  ENDLOOP.

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

  alv_grid_header->get_selected_rows( IMPORTING et_index_rows = DATA(rows) ).

  IF rows IS INITIAL.
    MESSAGE s035(zrwbfbpmc0001) DISPLAY LIKE 'W'. "Nenhuma linha selecionada, tente novamente!
    RETURN.
  ENDIF.

  TRY.
      DATA(shipment_request) = output_header[ rows[ 1 ]-index ].
    CATCH cx_sy_itab_line_not_found.
      CLEAR:shipment_request.
  ENDTRY.

  DATA(return) = NEW zrwbfbpcl_shipment_req_delete( shipment_request-id )->delete(  ).

  PERFORM refresh_from_db.
  PERFORM display_messages USING return.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form UPDATE_STATUS_SEPARATE
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_status_separate USING row TYPE zrwbfbps0008.

  DATA(update_from_data) = VALUE zrwbfbps0013( shipment_request      = row-id
                                               shipment_request_item = output_item
                                               status                = 'SE'
                                               status_description    = 'Separação' ).

  DATA(return) = NEW zrwbfbpcl_ship_req_upd_status( update_from_data )->update(  ).

  PERFORM display_messages USING return.

  IF return-type = 'S'.
    check_status = 'SE'.
  ELSE.
    check_status = 'PL'.
  ENDIF.

  SET HANDLER handle_event=>handle_hotspot_click FOR alv_grid_item.

  PERFORM refresh_from_db.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form UPDATE_STATUS_CHECKOUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_status_checkout USING row TYPE zrwbfbps0008.

  DATA(update_from_data) = VALUE zrwbfbps0013( shipment_request      = row-id
                                               shipment_request_item = output_item
                                               status                = 'CH'
                                               status_description    = 'Checkout' ).

  DATA(return) = NEW zrwbfbpcl_ship_req_upd_status( update_from_data )->update(  ).

  PERFORM display_messages USING return.

  IF return-type = 'S'.
    check_status = 'CH'.
  ELSE.
    check_status = 'SE'.
  ENDIF.

  SET HANDLER handle_event=>handle_hotspot_click FOR alv_grid_item.

  PERFORM refresh_from_db.

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

  alv_grid_item->get_selected_rows( IMPORTING et_index_rows = DATA(rows) ).

  IF rows IS INITIAL.
    MESSAGE s035(zrwbfbpmc0001) DISPLAY LIKE 'W'. "Nenhuma linha selecionada, tente novamente!
    RETURN.
  ENDIF.

  TRY.
      line = output_item[ rows[ 1 ]-index ].
    CATCH cx_sy_itab_line_not_found.
      CLEAR:line.
  ENDTRY.

  IF line-version = 0.
    MESSAGE s047(zrwbfbpmc0001) DISPLAY LIKE 'W' WITH line-picking_task. "Não há histórico de versões para a tarefa de separação &.
    RETURN.
  ENDIF.

  output_historic = NEW zrwbfbpcl_picking_task_hist( line )->get(  ).

  CALL SCREEN 9002 STARTING AT 50 5
                     ENDING AT 113 17.

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
*& Form UPDATE_STATUS_CANCEL
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_status_cancel .

  alv_grid_header->get_selected_rows( IMPORTING et_index_rows = DATA(rows) ).

  IF rows IS INITIAL.

    MESSAGE e026(zrwbfbpmc0001). "Selecione uma linha e tente novamente!
    RETURN.

  ENDIF.

  AUTHORITY-CHECK OBJECT 'ZUSER_CHEC'
                      ID 'ACTVT' FIELD '23'.

  IF sy-subrc = 0.

    LOOP AT rows INTO DATA(row).

      TRY.
          DATA(shipment_request_data) = header_data[ row-index ] .
        CATCH cx_sy_itab_line_not_found.
          CLEAR:shipment_request.
      ENDTRY.

      DATA(update_from_data) = VALUE zrwbfbps0013( shipment_request   = shipment_request_data-id
                                                   status             = 'CA'
                                                   status_description = 'Cancelado' ).



      DATA(return) = NEW zrwbfbpcl_ship_req_upd_status( update_from_data )->update(  ).

      PERFORM display_messages USING return.

      CHECK return-type = 'S'.
      PERFORM refresh_from_db.

    ENDLOOP.

  ELSE.

    MESSAGE s033(zrwbfbpmc0001) DISPLAY LIKE 'E' WITH sy-uname. "Função não autorizada ao usuário & .
    RETURN.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data.

  CLEAR:header_data.

  SELECT * FROM zrwbfbpt0001 INTO TABLE header_data WHERE id                    IN s_ship
                                                      AND plant                 IN s_plant
                                                      AND status                IN s_stat
                                                      AND customer              IN s_cust
                                                      AND plate_id              IN s_plate
                                                      AND driver_name           IN s_name
                                                      AND vehicle_type          IN s_veih
                                                      AND departure_date        IN s_date
                                                      AND transport_type        IN s_tran
                                                      AND shipping_company_code IN s_comp
                                                      AND deleted               = abap_false.
  SORT header_data BY id.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form BUILD
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build.

  CLEAR: output_header.

  LOOP AT header_data INTO DATA(header).

    APPEND VALUE #( id                         = header-id
                    icon                       = COND #(  WHEN header-status = 'CO' THEN icon_green_light
                                                          WHEN header-status = 'CA' THEN icon_red_light
                                                          ELSE icon_yellow_light )
                    status                     = header-status
                    status_description         = header-status_description
                    update_status              = COND #( WHEN header-status = 'PL' THEN 'Iniciar Separação'
                                                         WHEN header-status = 'SE' THEN 'Iniciar Checkout'
                                                         ELSE '' )
                    customer                   = header-customer
                    corporate_name             = header-corporate_name
                    plant                      = header-plant
                    plant_description          = header-plant_description
                    street                     = header-street
                    address_number             = header-address_number
                    district                   = header-district
                    zip_code                   = header-zip_code
                    city                       = header-city
                    state                      = header-state
                    country                    = header-country
                    shipping_company_code      = header-shipping_company_code
                    shipping_company           = header-shipping_company
                    driver_name                = header-driver_name
                    vehicle_type               = header-vehicle_type
                    vehicle_type_description   = header-vehicle_type_description
                    plate_id                   = header-plate_id
                    transport_type             = header-transport_type
                    transport_type_description = header-transport_type_description
                    departure_date_planned     = header-departure_date_planned
                    departure_time_planned     = header-departure_time_planned
                    departure_date             = header-departure_date
                    departure_time             = header-departure_time
                    toll_value                 = header-toll_value
                    currency                   = header-currency
                    gross_weight               = header-gross_weight
                    unit_weight                = header-unit_weight
                    create_date                = header-create_date
                    create_time                = header-create_time
                    create_user                = header-create_user ) TO output_header.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form SPLIT_CONTAINER
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM split_container.

  custom_container   = NEW #( container_name = 'MAIN_CONTAINER' ).

  splitter_container = NEW #( parent  =  custom_container
                              rows    = 2
                              columns = 1 ).

  splitter_container->set_row_height( id     = '1'
                                      height = '60' ).

  splitter_container->set_column_width( id    = '1'
                                        width = '32' ).

  splitter_container->get_container( EXPORTING
                                      row    = '1'
                                      column = '1'
                                     RECEIVING
                                      container = container_alv_header ).

  splitter_container->get_container( EXPORTING
                                      row    = '2'
                                      column = '1'
                                     RECEIVING
                                      container = container_alv_item ).

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

  alv_grid_header->get_selected_rows( IMPORTING et_index_rows = DATA(rows) ).

  IF rows IS INITIAL.
    MESSAGE s035(zrwbfbpmc0001) DISPLAY LIKE 'W'. "Nenhuma linha selecionada, tente novamente!
    EXIT.
  ENDIF.

  NEW zrwbfbpcl_shipment_req_print( shipment_request_id )->call_print(  ).

ENDFORM.


*&---------------------------------------------------------------------*
*& Form  HEADER_FIELDCATALOG
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
* Create a field catalogue from any internal table
*----------------------------------------------------------------------*
*      -->PT_TABLE     Internal table
*      -->PT_FIELDCAT  Field Catalogue
*----------------------------------------------------------------------*
FORM header_fieldcatalog USING    internal_table TYPE ANY TABLE
                         CHANGING fieldcatalog   TYPE lvc_t_fcat.

  fieldcatalog = VALUE lvc_t_fcat( ( col_pos = 1  fieldname = 'ID'                    coltext = 'Solicitação de transporte' outputlen = 20 key = abap_true hotspot = abap_true                                                                    )
                                   ( col_pos = 2  fieldname = 'ICON'                  coltext = 'S'                         outputlen = 3  just = 'C'                                                                                             )
                                   ( col_pos = 3  fieldname = 'STATUS_DESCRIPTION'    coltext = 'Status'                    outputlen = 10                                                                                                        )
                                   ( col_pos = 4  fieldname = 'UPDATE_STATUS'         coltext = 'Alterar status'            outputlen = 13 hotspot = abap_true style = cl_gui_alv_grid=>mc_style_button BIT-XOR cl_gui_alv_grid=>mc_style_hotspot )
                                   ( col_pos = 5  fieldname = 'CUSTOMER'              coltext = 'Cliente'                   outputlen = ''                                                                                                        )
                                   ( col_pos = 6  fieldname = 'CORPORATE_NAME'        coltext = 'Razão social'              outputlen = 25                                                                                                        )
                                   ( col_pos = 7  fieldname = 'PLANT'                 coltext = 'Centro'                    outputlen = 5                                                                                                         )
                                   ( col_pos = 8  fieldname = 'PLANT_DESCRIPTION'     coltext = 'Descrição'                 outputlen = ''                                                                                                        )
                                   ( col_pos = 9  fieldname = 'STREET'                coltext = 'Rua'                       outputlen = 15                                                                                                        )
                                   ( col_pos = 10 fieldname = 'ADDRESS_NUMBER'        coltext = 'Nº'                        outputlen = 5                                                                                                         )
                                   ( col_pos = 11 fieldname = 'DISTRICT'              coltext = 'Bairro'                    outputlen = 15                                                                                                        )
                                   ( col_pos = 12 fieldname = 'ZIP_CODE'              coltext = 'Código Postal'             outputlen = ''                                                                                                        )
                                   ( col_pos = 13 fieldname = 'CITY'                  coltext = 'Cidade'                    outputlen = ''                                                                                                        )
                                   ( col_pos = 14 fieldname = 'STATE'                 coltext = 'UF'                        outputlen = ''                                                                                                        )
                                   ( col_pos = 15 fieldname = 'COUNTRY'               coltext = 'Chave do país/região'      outputlen = ''                                                                                                        )
                                   ( col_pos = 16 fieldname = 'SHIPPING_COMPANY_CODE' coltext = 'Cód.'                      outputlen = ''                                                                                                        )
                                   ( col_pos = 17 fieldname = 'SHIPPING_COMPANY'      coltext = 'Transportadora'            outputlen = 25                                                                                                        ) ).

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZRWBFBPS0008'
      i_client_never_display = 'X'
      i_internal_tabname     = 'OUTPUT_HEADER'
    CHANGING
      ct_fieldcat            = fieldcatalog
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  DELETE fieldcatalog WHERE fieldname = 'DELETED'.
  DELETE fieldcatalog WHERE fieldname = 'STATUS'.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form  ITEM_FIELDCATALOG
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
* Create a field catalogue from any internal table
*----------------------------------------------------------------------*
*      -->PT_TABLE     Internal table
*      -->PT_FIELDCAT  Field Catalogue
*----------------------------------------------------------------------*
FORM item_fieldcatalog.

  fieldcat_item = VALUE lvc_t_fcat( ( col_pos = 1  fieldname = 'ID'                   coltext = 'Solicitação de transporte' outputlen = 18 key = abap_true    )
                                    ( col_pos = 2  fieldname = 'DELIVERY'             coltext = 'Remessa'                   outputlen = 10 key = abap_true    )
                                    ( col_pos = 3  fieldname = 'ITEM'                 coltext = 'Item'                      outputlen = 6  key = abap_true    )
                                    ( col_pos = 4  fieldname = 'PICKING_TASK'         coltext = 'Tarefa de separação'       outputlen = 15                    )
                                    ( col_pos = 5  fieldname = 'VERSION'              coltext = 'Versão'                    outputlen = 5                     )
                                    ( col_pos = 6  fieldname = 'ICON'                 coltext = 'S'                         outputlen = 3 just = 'C'          )
                                    ( col_pos = 7  fieldname = 'STATUS_DESCRIPTION'   coltext = 'Status'                    outputlen = 15                    )
                                    ( col_pos = 8  fieldname = 'MATERIAL'             coltext = 'Material'                  outputlen = 15                    )
                                    ( col_pos = 9  fieldname = 'MATERIAL_DESCRIPTION' coltext = 'Descrição do material'     outputlen = 28                    )
                                    ( col_pos = 10 fieldname = 'MATERIAL_QUANTITY'    coltext = 'Quantidade'                outputlen = 10                    )
                                    ( col_pos = 11 fieldname = 'UNIT_MEASUREMENT'     coltext = 'UMB'                       outputlen = 4                     )
                                    ( col_pos = 12 fieldname = 'QUANTITY'             coltext = 'Quantidade separada'       outputlen = 16                    )
                                    ( col_pos = 13 fieldname = 'UNIT'                 coltext = 'UMB'                       outputlen = 4                     )
                                    ( col_pos = 14 fieldname = 'GROSS_WEIGHT'         coltext = 'Peso bruto separado'       outputlen = 18 do_sum = abap_true )
                                    ( col_pos = 15 fieldname = 'UNIT_WEIGHT'          coltext = 'Un.'                       outputlen = 4                     )
                                    ( col_pos = 17 fieldname = 'USER_RESPONSIBLE'     coltext = 'Usuario responsavel'       outputlen = 15                    ) ).

  fieldcat_historic = VALUE lvc_t_fcat( ( col_pos = 1 fieldname = 'PICKING_TASK'      coltext = 'Tarefa de separação'  outputlen = 15 key = abap_true )
                                        ( col_pos = 2 fieldname = 'VERSION'           coltext = 'Versão'               outputlen = 6  key = abap_true )
                                        ( col_pos = 3 fieldname = 'SEPARATE_QUANTITY' coltext = 'Quantidade'           outputlen = 10                 )
                                        ( col_pos = 4 fieldname = 'UNIT_MEASUREMENT'  coltext = 'Un.'                  outputlen = 3                  )
                                        ( col_pos = 5 fieldname = 'QUANTITY_SEPARATE' coltext = 'Quantidade separada'  outputlen = 15                 )
                                        ( col_pos = 6 fieldname = 'UNIT'              coltext = 'Un.'                  outputlen = 3                  )
                                        ( col_pos = 7 fieldname = 'USER_RESPONSIBLE'  coltext = 'Usuario responsavel'  outputlen = 15                 ) ).

  DELETE fieldcat_item WHERE fieldname = 'DELETED'.

ENDFORM.
