CLASS zrwbfbpcl_get_descr_field DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING screen_fields TYPE zrwbfbpt0001.

    METHODS retrieve_status
      RETURNING
        VALUE(return) TYPE zrwbfbpt0001-status_description .

    METHODS retrieve_plant
      RETURNING
        VALUE(return) TYPE zrwbfbpt0001-plant_description .

    METHODS retrieve_transport_type
      RETURNING
        VALUE(return) TYPE zrwbfbpt0001-transport_type_description .

    METHODS retrieve_shipping_company
      RETURNING
        VALUE(return) TYPE zrwbfbpt0001-shipping_company .

    METHODS retrieve_vehicle_type
      RETURNING
        VALUE(return) TYPE zrwbfbpt0001-vehicle_type_description .

  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA: screen_fields TYPE zrwbfbpt0001.

    METHODS setup.
    METHODS fill_status.
    METHODS fill_plant.
    METHODS fill_transport_type.
    METHODS fill_shipping_company.
    METHODS fill_vehicle_type.

ENDCLASS.



CLASS zrwbfbpcl_get_descr_field IMPLEMENTATION.


  METHOD constructor.

    me->screen_fields = screen_fields.
    me->setup( ).

  ENDMETHOD.


  METHOD setup.

    me->fill_plant(  ).
    me->fill_shipping_company(  ).
    me->fill_status(  ).
    me->fill_transport_type(  ).
    me->fill_vehicle_type(  ).

  ENDMETHOD.


  METHOD fill_plant.

    SELECT SINGLE name1 FROM t001w INTO me->screen_fields-plant_description WHERE werks = screen_fields-plant.

  ENDMETHOD.


  METHOD fill_shipping_company.

    DATA(lifnr) = |{ me->screen_fields-shipping_company_code ALPHA = IN }|.

    SELECT SINGLE name1 FROM lfa1 INTO me->screen_fields-shipping_company WHERE lifnr = lifnr.

  ENDMETHOD.


  METHOD fill_status.

    SELECT SINGLE ddtext FROM dd07t INTO me->screen_fields-status_description WHERE domname    = 'ZRWBFBPDO0001'
                                                                                AND domvalue_l = me->screen_fields-status.

  ENDMETHOD.


  METHOD fill_transport_type.

    DATA(shtyp) = screen_fields-transport_type.

    SELECT SINGLE bezei FROM tvtkt INTO me->screen_fields-transport_type_description WHERE shtyp = shtyp
                                                                                       AND spras = sy-langu.

  ENDMETHOD.


  METHOD fill_vehicle_type.

    SELECT SINGLE ddtext FROM dd07t INTO me->screen_fields-vehicle_type_description WHERE domname    = 'ZRWBFBPDO0002'
                                                                                      AND domvalue_l = me->screen_fields-vehicle_type
                                                                                      AND ddlanguage = sy-langu.

  ENDMETHOD.


  METHOD retrieve_plant.
    return = me->screen_fields-plant_description.
  ENDMETHOD.


  METHOD retrieve_shipping_company.
    return = me->screen_fields-shipping_company.
  ENDMETHOD.


  METHOD retrieve_status.
    return = me->screen_fields-status_description.
  ENDMETHOD.


  METHOD retrieve_transport_type.
    return = me->screen_fields-transport_type_description.
  ENDMETHOD.


  METHOD retrieve_vehicle_type.
    return = me->screen_fields-vehicle_type_description.
  ENDMETHOD.

ENDCLASS.
