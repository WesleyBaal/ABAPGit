*- SAP------------------------------------------------------------SAP -*
*-   ***        Tracking de Solicitações de Transporte         ***    -*
*- SAP------------------------------------------------------------SAP -*
************************************************************************
* Projeto: First Big Project Challenge - ABAP
* Modulo / Componente:
*
* Report: ZRWBFBPPR0003
* Descrição: Tracking de Solicitações de Transporte
*
* Modo Execução: [] Background * [X] Online
*
************************************************************************
* Autor: Wesley Baal                                    Data: 28/11/2023
*
************************************************************************
* Modificações:
*
************************************************************************
PROGRAM zrwbfbppr0003.

INCLUDE zrwbfbppr0003top.
INCLUDE zrwbfbppr0003c01.
INCLUDE zrwbfbppr0003f01.
INCLUDE zrwbfbppr0003o01.
INCLUDE zrwbfbppr0003i01.

START-OF-SELECTION.

  PERFORM get_data.
  PERFORM build.

END-OF-SELECTION.

  IF header_data IS NOT INITIAL.
    CALL SCREEN 9001.
  ELSE.
    MESSAGE s008(zrwbfbpmc0001) DISPLAY LIKE 'E'. "Nenhuma solicitação de transporte encontrada.
  ENDIF.
