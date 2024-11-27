CLASS zrwbfbpcl_ship_req_upd_status DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        update_from_data TYPE zrwbfbps0013 .

    METHODS update
      RETURNING
        VALUE(return) TYPE bapiret2.

  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA: update_from_data TYPE zrwbfbps0013,
          answer           TYPE char10,
          messages         TYPE bapiret2.

    METHODS call_popup.
    METHODS rules.

ENDCLASS.


CLASS zrwbfbpcl_ship_req_upd_status IMPLEMENTATION.


  METHOD constructor.

    me->update_from_data = update_from_data.

    me->call_popup(  ).
    me->rules(  ).

  ENDMETHOD.

  METHOD call_popup.

    DATA(status) = me->update_from_data-status_description.
    TRANSLATE status TO UPPER CASE.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = ''
        text_question         = |Deseja alterar o status da solicitação de transporte { me->update_from_data-shipment_request } para { status }?|
        text_button_1         = 'Ok'
        icon_button_1         = 'ICON_CHECKED'
        text_button_2         = 'Cancel'
        icon_button_2         = 'ICON_CANCEL'
        display_cancel_button = ' '
        popup_type            = 'ICON_MESSAGE_QUESTION'
      IMPORTING
        answer                = me->answer.

  ENDMETHOD.


  METHOD rules.

    CASE me->update_from_data-status.

      WHEN 'CH'.

        IF NOT line_exists( me->update_from_data-shipment_request_item[ status = 'F' ] ).

          me->messages = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                            type   = 'E'
                                                            number = '024' ). "Nenhuma tarefa de separação finalizada.
          RETURN.

        ENDIF.

      WHEN 'SE'.

        IF me->update_from_data-shipment_request_item IS INITIAL.

          me->messages = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                            type   = 'E'
                                                            number = '031'
                                                            var1   = CONV #( me->update_from_data-shipment_request )
                                                            var2   = 'SE' )."Nenhum item relacionado a solicitação de transporte "&"!
          RETURN.

        ENDIF.

        IF line_exists( me->update_from_data-shipment_request_item[ picking_task = space ] ).

          me->messages = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                            type   = 'E'
                                                            number = '014' ). "Tarefa de separação é obrigatória para todos os itens!
          RETURN.

        ENDIF.

    ENDCASE.


  ENDMETHOD.


  METHOD update.

    CHECK me->answer = 1.

    IF me->messages-type = 'E'.
      return = me->messages.
    ELSE.

      return = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                  type   = 'S'
                                                  number = '011'
                                                  var1   = CONV #( me->update_from_data-shipment_request ) ) . "Status da Solicitação & de Transporte foi Atualizado!

      UPDATE zrwbfbpt0001 SET status             = me->update_from_data-status
                              status_description = me->update_from_data-status_description WHERE id = me->update_from_data-shipment_request.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
