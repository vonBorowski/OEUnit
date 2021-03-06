/*------------------------------------------------------------------------------
  File        : Errors.cls
  Package     : OEUnit.Util
  Description : Helper methods for extracting error messages from the 
                ERROR-STATUS/COMPILER system handles and instances of 
                Progress.Lang.Error.
------------------------------------------------------------------------------*/
ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS OEUnit.Util.Errors:

  METHOD PUBLIC STATIC VOID Initalize():
  END METHOD.
  
  /*----------------------------------------------------------------------------
    Returns a concatenated string of all error messages in the given handle.
  ----------------------------------------------------------------------------*/
  METHOD PUBLIC STATIC CHARACTER GetMessage(INPUT hError AS HANDLE):
  
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
    DEFINE VARIABLE errorMessage AS CHARACTER NO-UNDO.
    
    IF hError:ERROR THEN DO:
      DO i = 1 TO hError:NUM-MESSAGES:
        errorMessage = errorMessage + (IF errorMessage <> "" THEN ". " ELSE "") 
          + hError:GET-MESSAGE(i).
      END.
    END.
    RETURN errorMessage.
  END METHOD.


  /*----------------------------------------------------------------------------
    Returns a concatenated string of all error messages contained in the given
    Progress.Lang.Error object.
  ----------------------------------------------------------------------------*/
  METHOD PUBLIC STATIC CHARACTER GetMessage(INPUT err AS Progress.Lang.Error):
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
    DEFINE VARIABLE errorMessage AS CHARACTER NO-UNDO.
    
    IF TYPE-OF(err, Progress.Lang.AppError) THEN
      errorMessage = CAST(err, Progress.Lang.AppError):ReturnValue. 
    
    DO i = 1 TO err:NumMessages:
      errorMessage = errorMessage + (IF errorMessage <> "" THEN ". " ELSE "") 
        + err:GetMessage(i) 
        + (IF err:GetMessageNum(i) <> 0 THEN 
          " (" + STRING(err:GetMessageNum(i)) + ")"
          ELSE "").
    END.
    RETURN errorMessage.
  END METHOD.
  
  /*----------------------------------------------------------------------------
    Truncate noisy OEUnit stack trace lines from error's callstack 
  ----------------------------------------------------------------------------*/  
  METHOD PUBLIC STATIC CHARACTER TrimCallStack(INPUT callStack AS CHARACTER):
    
    DEFINE VARIABLE trimmed AS CHARACTER NO-UNDO.
    DEFINE VARIABLE stackLine AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
    DO i = 1 TO NUM-ENTRIES(callStack, "~n"):
        stackLine = ENTRY(i, callStack, "~n").
        IF stackLine BEGINS "Invoke OEUnit.Reflection.MethodInfo" THEN DO:
            trimmed = trimmed + ". . .".
            RETURN trimmed.
        END.
        IF NOT stackLine MATCHES "* OEUnit.Assertion.Assert at*" THEN
            trimmed = trimmed + stackLine + "~n".
    END.
    
    RETURN callStack.
  END METHOD.

END CLASS.