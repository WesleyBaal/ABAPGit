CLASS zrwbfbpcl_shipment_req_create DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        shipment_request_data TYPE zrwbfbps0003 .

    METHODS create
      EXPORTING
        VALUE(shipment_request_id) TYPE char10
      RETURNING
        VALUE(return)              TYPE bapiret2.

  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA: shipment_request    TYPE zrwbfbps0003,
          header_data         TYPE zrwbfbpt0001,
          shipment_request_id TYPE char10,
          messages            TYPE bapiret2,
          regex               TYPE REF TO cl_abap_regex,
          matcher             TYPE REF TO cl_abap_matcher,
          item_data           TYPE TABLE OF zrwbfbpt0002.

    METHODS check_fields.
    METHODS setup.
    METHODS build.
    METHODS number_next.

ENDCLASS.


CLASS zrwbfbpcl_shipment_req_create IMPLEMENTATION.


  METHOD constructor.

    me->shipment_request = shipment_request_data.
    me->check_fields(  ).
    me->setup(  ).

  ENDMETHOD.


  METHOD setup.

    me->number_next(  ).
    me->build(  ).

  ENDMETHOD.


  METHOD create.

    IF messages-type = 'E'.
      return = me->messages.
    ELSE.

      MODIFY zrwbfbpt0001 FROM me->header_data.
      MODIFY zrwbfbpt0002 FROM TABLE me->item_data.

      return = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                  type   = 'S'
                                                  number = '030'
                                                  var1   = CONV #( me->shipment_request_id ) ) . "Solicitação de transporte "&" criada com êxito!
    ENDIF.

    shipment_request_id = me->shipment_request_id.

  ENDMETHOD.


  METHOD number_next.

    CHECK me->messages-type <> 'E'.

    DATA: nr_range_nr TYPE nrnr,
          object      TYPE inri-object,
          number      TYPE p.

    CLEAR: me->shipment_request_id.

    object      = 'ZRWBFBP_SR'.
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

    me->shipment_request_id = number.

  ENDMETHOD.


  METHOD check_fields.

    CREATE OBJECT me->regex
      EXPORTING
        pattern     = '^[A-Z]{3}[0-9]{4}$'
        ignore_case = abap_false.

    me->matcher = me->regex->create_matcher( text = me->shipment_request-customer_data-plate_id ).

    IF me->shipment_request-customer_data-departure_date_planned IS INITIAL OR
       me->shipment_request-customer_data-plant                  IS INITIAL OR
       me->shipment_request-customer_data-departure_time_planned IS INITIAL OR
       me->shipment_request-customer_data-driver_name            IS INITIAL OR
       me->shipment_request-customer_data-plate_id               IS INITIAL OR
       me->shipment_request-customer_data-shipping_company_code  IS INITIAL OR
       me->shipment_request-customer_data-transport_type         IS INITIAL OR
       me->shipment_request-customer_data-vehicle_type           IS INITIAL.

      me->messages = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                        type   = 'E'
                                                        number = '005' ). "É obrigatório preencher todos os campos para concluir o cadastro!

      RETURN.

    ENDIF.

    IF matcher->match( ) IS INITIAL.

      me->messages = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                        type   = 'E'
                                                        number = '048' ). "Placa de veículo inválida!

      RETURN.

    ENDIF.

    IF me->shipment_request-delivery_data IS INITIAL.

      me->messages = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                        type   = 'E'
                                                        number = '045' ). "É obrigatório ao menos uma remessa para concluir o cadastro!

      RETURN.

    ENDIF.

  ENDMETHOD.


  METHOD build.

    LOOP AT me->shipment_request-delivery_data INTO DATA(output).

      APPEND VALUE zrwbfbpt0002( id                   = me->shipment_request_id
                                 picking_task         = output-picking_task
                                 delivery             = output-delivery
                                 item                 = output-item
                                 material             = output-material
                                 material_description = output-material_description
                                 material_quantity    = output-material_quantity
                                 unit_measurement     = output-unit_measurement
                                 gross_weight         = output-gross_weight
                                 unit_weight          = output-unit_weight ) TO me->item_data.

    ENDLOOP.

    me->header_data = VALUE #( id                         = me->shipment_request_id
                               status                     = me->shipment_request-customer_data-status
                               status_description         = me->shipment_request-customer_data-status_description
                               customer                   = me->shipment_request-customer_data-customer
                               corporate_name             = me->shipment_request-customer_data-corporate_name
                               plant                      = me->shipment_request-customer_data-plant
                               plant_description          = me->shipment_request-customer_data-plant_description
                               street                     = me->shipment_request-customer_data-street
                               address_number             = me->shipment_request-customer_data-address_number
                               district                   = me->shipment_request-customer_data-district
                               zip_code                   = me->shipment_request-customer_data-zip_code
                               city                       = me->shipment_request-customer_data-city
                               state                      = me->shipment_request-customer_data-state
                               country                    = me->shipment_request-customer_data-country
                               shipping_company_code      = me->shipment_request-customer_data-shipping_company_code
                               shipping_company           = me->shipment_request-customer_data-shipping_company
                               driver_name                = me->shipment_request-customer_data-driver_name
                               vehicle_type               = me->shipment_request-customer_data-vehicle_type
                               vehicle_type_description   = me->shipment_request-customer_data-vehicle_type_description
                               plate_id                   = me->shipment_request-customer_data-plate_id
                               transport_type             = me->shipment_request-customer_data-transport_type
                               transport_type_description = me->shipment_request-customer_data-transport_type_description
                               departure_date_planned     = me->shipment_request-customer_data-departure_date_planned
                               departure_time_planned     = me->shipment_request-customer_data-departure_time_planned
                               departure_date             = me->shipment_request-customer_data-departure_date
                               departure_time             = me->shipment_request-customer_data-departure_time
                               toll_value                 = COND #( WHEN me->shipment_request-customer_data-toll_value IS INITIAL THEN '0.00'
                                                                      ELSE me->shipment_request-customer_data-toll_value )
                               currency                   = 'BRL'
                               gross_weight               = me->shipment_request-customer_data-gross_weight
                               unit_weight                = me->shipment_request-customer_data-unit_weight
                               create_date                = sy-datum
                               create_time                = sy-uzeit
                               create_user                = sy-uname ) .

  ENDMETHOD.

ENDCLASS.
