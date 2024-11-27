CLASS zrwbfbpcl_delete_duplicates DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING shipment_request TYPE zrwbfbpt0001-id.

    METHODS change
      CHANGING delivery_data TYPE zrwbfbps0003.


  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA: shipment_request_data TYPE zrwbfbps0003,
          delivery_data         TYPE zrwbfbps0003.


    METHODS setup.

    METHODS delete
      CHANGING delivery_data TYPE zrwbfbps0003.

ENDCLASS.


CLASS zrwbfbpcl_delete_duplicates IMPLEMENTATION.


  METHOD constructor.

    me->shipment_request_data-customer_data-id = shipment_request.
    me->setup( ).

  ENDMETHOD.


  METHOD setup.

    DATA(return) = NEW zrwbfbpcl_get_shipment_request(  me->shipment_request_data-customer_data-id )->get( IMPORTING shipment_request_data = me->shipment_request_data ).

  ENDMETHOD.


  METHOD change.

    me->delete( CHANGING delivery_data = delivery_data ).

  ENDMETHOD.


  METHOD delete.

    LOOP AT me->shipment_request_data-delivery_data INTO DATA(shipment_request).

      DELETE delivery_data-delivery_data WHERE delivery = shipment_request-delivery .

    ENDLOOP.

  ENDMETHOD.


ENDCLASS.
