CLASS zrwbfbpcl_picking_task_print DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        task_data TYPE zrwbfbps0009 .
    METHODS call_print .
  PRIVATE SECTION.

    DATA: task_data             TYPE zrwbfbps0009,
          confirmation_id       TYPE char10,
          print_data            TYPE zrwbfbps0009,
          transport_header      TYPE zrwbfbpt0001,
          print_parameters      TYPE pri_params,
          valid_flag            TYPE c LENGTH 1,
          lv_destination        TYPE rspopname,
          lv_no_dialog(01)      TYPE c,
          shipment_request      TYPE zrwbfbpt0001-id,
          shipment_request_data TYPE zrwbfbps0003,
          tags                  TYPE zrwbfbps0012_tab.

    METHODS setup.
    METHODS number_next.
    METHODS get_data.
    METHODS build.
    METHODS print_smartforms.
    METHODS print_zpl.

ENDCLASS.


CLASS zrwbfbpcl_picking_task_print IMPLEMENTATION.


  METHOD constructor.

    me->task_data = task_data.
    me->setup(  ).

  ENDMETHOD.


  METHOD setup.

    me->number_next(  ).
    me->get_data(  ).
    me->build(  ).

  ENDMETHOD.


  METHOD number_next.

    DATA: nr_range_nr TYPE nrnr,
          object      TYPE inri-object,
          number      TYPE p.

    CLEAR: me->confirmation_id.

    object      = 'ZRWBFBP_ID'.
    nr_range_nr = '01'.

    CALL FUNCTION 'NUMBER_RANGE_ENQUEUE'
      EXPORTING
        object           = object
      EXCEPTIONS
        foreign_lock     = 1
        object_not_found = 2
        system_failure   = 3
        OTHERS           = 4.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = nr_range_nr
        object                  = object
      IMPORTING
        number                  = number
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.

    CALL FUNCTION 'NUMBER_RANGE_DEQUEUE'
      EXPORTING
        object = object.

    me->confirmation_id = number.

  ENDMETHOD.


  METHOD call_print.

    me->print_zpl(  ).
    me->print_smartforms(  ).

  ENDMETHOD.


  METHOD get_data.

    SELECT SINGLE * FROM zrwbfbpt0001 INTO me->transport_header WHERE id = me->task_data-id.

  ENDMETHOD.


  METHOD build.

    DATA(input) = me->task_data-uom.
    DATA(output) = zrwbfbpcl_utilities=>convert_output_by_convexit( convexit = 'CUNIT'
                                                                    value    =  input ).

    me->print_data = VALUE zrwbfbps0009( id                       = me->transport_header-id
                                         shipping_company         = me->transport_header-shipping_company(20)
                                         vehicle_type_description = me->transport_header-vehicle_type_description
                                         plate_id                 = me->transport_header-plate_id
                                         driver_name              = me->transport_header-driver_name
                                         departure_date_planned   = me->transport_header-departure_date_planned
                                         departure_time_planned   = me->transport_header-departure_time_planned
                                         id_confirmation          = me->confirmation_id
                                         picking_task             = me->task_data-picking_task
                                         version                  = me->task_data-version
                                         material                 = me->task_data-material(12)
                                         material_description     = COND #( WHEN me->task_data-material_description IS INITIAL THEN 'CANETA'
                                                                                ELSE me->task_data-material_description(25) )
                                         quantity                 = 1
                                         uom                      = output ).

    me->tags = VALUE zrwbfbps0012_tab( ( tag   = '<(>&<)>ID&'                   value = me->print_data-id                                               )
                                       ( tag   = '<(>&<)>COMPANY&'              value = me->print_data-shipping_company(20)                             )
                                       ( tag   = '<(>&<)>VEHICLE&'              value = me->print_data-vehicle_type_description                         )
                                       ( tag   = '<(>&<)>PLATE&'                value = me->print_data-plate_id                                         )
                                       ( tag   = '<(>&<)>DATE&'                 value = me->print_data-departure_date_planned+6(2) && '.' &&
                                                                                        me->print_data-departure_date_planned+4(2) && '.' &&
                                                                                        me->print_data-departure_date_planned(4)                        )
                                       ( tag   = '<(>&<)>TIME&'                 value = me->print_data-departure_time_planned(2)   && ':' &&
                                                                                        me->print_data-departure_time_planned+2(2) && ':' && '00'       )
                                       ( tag   = '<(>&<)>CONFIRMED_ID&'         value = me->print_data-id_confirmation                                  )
                                       ( tag   = '<(>&<)>PICKING_TASK&'         value = me->print_data-picking_task                                     )
                                       ( tag   = '<(>&<)>MATERIAL&'             value = me->print_data-material(12)                                     )
                                       ( tag   = '<(>&<)>MATERIAL_DESCRIPTION&' value = COND #( WHEN me->print_data-material_description IS INITIAL
                                                                                                     THEN 'CANETA'
                                                                                                         ELSE me->print_data-material_description(25) ) )
                                       ( tag   = '<(>&<)>QUANTITY&'             value = me->print_data-quantity                                         )
                                       ( tag   = '<(>&<)>UOM&'                  value = me->print_data-uom                                              ) ).

    DATA(data_confirmation) = VALUE zrwbfbpt0005( mandt        = sy-mandt
                                                  confirmed_id = me->confirmation_id
                                                  id           = me->task_data-id
                                                  picking_task = me->task_data-picking_task
                                                  version      = me->task_data-version
                                                  material     = me->task_data-material
                                                  quantity     = 1
                                                  uom          = me->task_data-uom
                                                  check_id     = abap_false ).

    MODIFY zrwbfbpt0005 FROM data_confirmation.

  ENDMETHOD.


  METHOD print_smartforms.

    DATA: name    TYPE rs38l_fnam,
          options TYPE ssfcompop,
          control TYPE ssfctrlop,
          printer TYPE rspopname.

    options = VALUE #( tddest   = printer
                       tdnoprev = 'X'
                       tdimmed  = 'X' ).

    control = VALUE #( no_dialog = 'X'
                       device    = 'PRINTER' ).

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = 'ZRWBFBPSF0002'
      IMPORTING
        fm_name            = name
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.

    CALL FUNCTION name
      EXPORTING
        control_parameters = control
        output_options     = options
        user_settings      = space
        print_data         = me->print_data
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

  ENDMETHOD.


  METHOD print_zpl.

    TRY.
        DATA(lt_label) = cl_wsd_utility=>get_long_text( i_id     = 'ST'
                                                        i_langu  = sy-langu
                                                        i_name   = 'ZRWBFBP_ZPL001'
                                                        i_object = 'TEXT' ).
      CATCH cx_wsd_exception .
    ENDTRY.

    LOOP AT me->tags INTO DATA(tag).
      REPLACE ALL OCCURRENCES OF tag-tag
       IN TABLE lt_label WITH tag-value
        RESPECTING CASE.
    ENDLOOP.

    CLEAR lv_destination.
    CALL FUNCTION 'FTR_CORR_CHECK_DEFAULT_PRINTER'
      EXPORTING
        i_uname        = sy-uname
      IMPORTING
        e_destination  = me->lv_destination
      EXCEPTIONS
        invalid        = 1
        no_destination = 2
        OTHERS         = 3.

    IF lv_destination IS INITIAL.
      lv_no_dialog = space.
    ELSE.
      lv_no_dialog = 'X'.
    ENDIF.

    CALL FUNCTION 'GET_PRINT_PARAMETERS'
      EXPORTING
        destination          = me->lv_destination
        immediately          = abap_true
        line_count           = 90
        line_size            = 120
        no_dialog            = me->lv_no_dialog
        layout               = 'X_90_120'
      IMPORTING
        out_parameters       = me->print_parameters
        valid                = me->valid_flag
      EXCEPTIONS
        invalid_print_params = 2
        OTHERS               = 4.

    IF me->print_parameters-pdest IS INITIAL.
      MESSAGE TEXT-e02 TYPE 'I'.
      EXIT.
    ENDIF.

    me->print_parameters-linct = 1000.

    NEW-PAGE PRINT ON PARAMETERS me->print_parameters NO DIALOG.

    LOOP AT lt_label ASSIGNING FIELD-SYMBOL(<fs_label>).
      WRITE:/ <fs_label>-tdline.
    ENDLOOP.

    NEW-PAGE PRINT OFF.

  ENDMETHOD.

ENDCLASS.
