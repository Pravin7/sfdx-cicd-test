public Interface TriggerHandlerInterface {
      void enter(TriggerParameter tp);
      boolean permit(TriggerParameter tp);//when this one is already executing and it causes some dml
}