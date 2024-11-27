*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0001F01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& Form EXECUTE
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM execute.

  DATA(count) = strlen( p_load ).

  count = count - 4.

  IF p_load+count(4) = 'xlsx'.
    check = abap_true.
    PERFORM upload_xlsx.
    PERFORM build.
  ELSE.
    check = abap_false.
    PERFORM upload_txt.
    PERFORM build.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form UPLOAD_TXT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM upload_txt.

  uploaded_data = NEW zrwbfbpcl_utilities(  )->upload( p_load ).

ENDFORM.


*&---------------------------------------------------------------------*
*& Form UPLOAD_XLSX
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM upload_xlsx.

  IF <output_data> IS ASSIGNED.
    CLEAR <output_data>. UNASSIGN <output_data>.
  ENDIF.

  TRY.
      DATA(uploader) =  NEW lcl_xlsx_uploader( filefullpath   = CONV #( p_load )
                                               structure_name = CONV #( 'ZRWBFBPS0001' )
                                               sheet_id       = CONV #( 1 ) ).

      uploader->import( ).

      DATA(table_type) = uploader->get_table_type( ).
      CREATE DATA tabledata TYPE HANDLE table_type.
      ASSIGN tabledata->* TO <output_data>.

      uploader->get_tablecontent( IMPORTING tablecontent = <output_data> ).

    CATCH lcx_xlsx_uploader INTO DATA(error) .
      MESSAGE error->local_text TYPE 'E'.
  ENDTRY.

  uploaded_data = <output_data>.

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

  LOOP AT uploaded_data ASSIGNING FIELD-SYMBOL(<uploaded>).

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = <uploaded>-material
      IMPORTING
        output = <uploaded>-material.

  ENDLOOP.

  SELECT * FROM mara INTO TABLE @DATA(material_data)
      FOR ALL ENTRIES IN @uploaded_data WHERE matnr = @uploaded_data-material .

  LOOP AT material_data INTO DATA(material).

    APPEND VALUE #( material             = material-matnr
                    material_description = material-matkl
                    gross_weight         = material-brgew
                    unit_weight          = COND #( WHEN material-gewei IS INITIAL THEN 'KG' ELSE material-gewei )
                    gross_weight_new     = uploaded_data[ 1 ]-gross_weight_new
                    unit_weight_new      = COND #( WHEN material-gewei IS INITIAL THEN 'KG' ELSE material-gewei )
                    umb                  = material-meins
                    status               = ''
                    messages             = '' ) TO output_data.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form EXECUTE_CHANGE
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM execute_change.

  alv_grid->get_selected_rows( IMPORTING et_index_rows = DATA(rows) ).

  LOOP AT rows INTO DATA(row).

    ASSIGN output_data[ row-index ] TO FIELD-SYMBOL(<alv_row>).

    IF <alv_row> IS ASSIGNED.

      PERFORM map_uploaded USING <alv_row> .

    ENDIF.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form MAP_UPLOADED
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM map_uploaded USING row TYPE zrwbfbps0001.

  LOOP AT output_data INTO DATA(output).

    headdata = VALUE bapimathead(  material = output-material  ).

    APPEND VALUE bapi_marm( alt_unit   = output-umb
                            numerator  = 1
                            denominatr = 1
                            gross_wt   = output-gross_weight_new
                            unit_of_wt = output-unit_weight ) TO unitsofmeasure.

    APPEND VALUE bapi_marmx( alt_unit   = output-umb
                             numerator  = 1
                             denominatr = 1
                             gross_wt   = abap_true
                             unit_of_wt = abap_true  ) TO unitsofmeasurex .

    PERFORM change_function CHANGING row.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form CHANGE_FUNCTION
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM change_function CHANGING row TYPE zrwbfbps0001.

  DATA: return         TYPE bapiret2,
        returnmessages TYPE TABLE OF bapi_matreturn2.

  CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
    EXPORTING
      headdata        = headdata
    IMPORTING
      return          = return
    TABLES
      unitsofmeasure  = unitsofmeasure
      unitsofmeasurex = unitsofmeasurex
      returnmessages  = returnmessages.

  IF return-type <> 'E'.

    COMMIT WORK AND WAIT.

    row-status   = icon_checked.
    row-messages = return-message.

  ELSE.

    ROLLBACK WORK.

    row-status   = icon_incomplete.
    row-messages = return-message.

  ENDIF.

  IF check = abap_true.
    PERFORM create_log_xlsx USING row.
  ELSE.
    PERFORM create_log_txt USING row.
  ENDIF.

  alv_grid->refresh_table_display( ).

ENDFORM.


*&---------------------------------------------------------------------*
*& Form CREATE_LOG_XLSX
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_log_xlsx USING row TYPE zrwbfbps0001.

  DATA: size       TYPE i,
        salv_table TYPE REF TO cl_salv_table,
        log        TYPE TABLE OF zrwbfbps0001,
        xlsx       TYPE xstring,
        log_path   TYPE string,
        bintab     TYPE solix_tab.

  cl_salv_table=>factory(
  IMPORTING
    r_salv_table = salv_table
  CHANGING
    t_table = output_data ).

  xlsx = salv_table->to_xml( if_salv_bs_xml=>c_type_xlsx ).
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = xlsx
    IMPORTING
      output_length = size
    TABLES
      binary_tab    = bintab.



  IF bintab IS INITIAL.
    RETURN.
  ENDIF.

  IF row-status = icon_checked.

    CONCATENATE p_log '\Success.xlsx' INTO log_path.

  ELSE.

    CONCATENATE p_log '\Error.xlsx' INTO log_path.

  ENDIF.

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      bin_filesize            = size
      filename                = log_path
      filetype                = 'BIN'
    CHANGING
      data_tab                = bintab
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form CREATE_LOG_TXT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_log_txt USING row TYPE zrwbfbps0001.

  DATA: log_path TYPE string,
        log      TYPE TABLE OF zrwbfbps0001.

  IF row-status = icon_checked.

    APPEND VALUE #( material             = row-material
                    material_description = row-material_description
                    gross_weight         = row-gross_weight
                    unit_weight          = row-unit_weight
                    gross_weight_new     = row-gross_weight_new
                    unit_weight_new      = row-unit_weight_new
                    messages             = row-messages ) TO log.

    CONCATENATE p_log '\Success' INTO log_path.
  ELSE.

    APPEND VALUE #( material             = row-material
                    material_description = row-material_description
                    gross_weight         = row-gross_weight
                    unit_weight          = row-unit_weight
                    gross_weight_new     = row-gross_weight_new
                    unit_weight_new      = row-unit_weight_new
                    messages             = row-messages ) TO log.

    CONCATENATE p_log '\Error' INTO log_path.

  ENDIF.

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = log_path
      filetype                = 'DAT'
    CHANGING
      data_tab                = log
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.

  IF sy-subrc <> 0.
    MESSAGE e002(zrwbfbpmc0001). "Falha na Geração do arquivo de log!
  ENDIF.

ENDFORM.


FORM on_f4 .

                 BREAK-POINT.
*
ENDFORM.


*&---------------------------------------------------------------------*
*& Form  FIELDCATALOG
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
* Create a field catalogue from any internal table
*----------------------------------------------------------------------*
*      -->PT_TABLE     Internal table
*      -->PT_FIELDCAT  Field Catalogue
*----------------------------------------------------------------------*
FORM fieldcatalog.

  fieldcat = VALUE lvc_t_fcat( ( col_pos = 1  fieldname = 'MATERIAL'             coltext = 'Material'              outputlen = 15 key = abap_true edit = abap_true )
                               ( col_pos = 2  fieldname = 'MATERIAL_DESCRIPTION' coltext = 'Descrição do material' outputlen = 25 f4availabl = 'X' EDIT = ABAP_TRUE  )
                               ( col_pos = 3  fieldname = 'GROSS_WEIGHT'         coltext = 'Atual peso bruto'      outputlen = 12 )
                               ( col_pos = 4  fieldname = 'UNIT_WEIGHT'          coltext = 'Un.'                   outputlen = 4  )
                               ( col_pos = 5  fieldname = 'GROSS_WEIGHT_NEW'     coltext = 'Novo peso bruto'       outputlen = 12 emphasize = abap_true )
                               ( col_pos = 6  fieldname = 'UNIT_WEIGHT_NEW'      coltext = 'Un.'                   outputlen = 4  emphasize = abap_true )
                               ( col_pos = 7  fieldname = 'STATUS'               coltext = 'ID'                    outputlen = 1  )
                               ( col_pos = 8  fieldname = 'MESSAGES'             coltext = 'Status'                outputlen = 30 ) ).

ENDFORM.
