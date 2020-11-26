global class MassNoteInsert{

  WebService static Integer insertNotes(String iTitle,
                                       String iBody,
                                       Id[] iParentIds) {
    Note[] notes = new Note[0];
    iBody = String.escapeSingleQuotes(iBody);
    for (Id iParentId : iParentIds) {
        notes.add(new Note(parentId = iParentId,
                           title = iTitle, body = iBody));
    }
    insert notes; //Bulk Insert 
    
    return notes.size();
  }

}