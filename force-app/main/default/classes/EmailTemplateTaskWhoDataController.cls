public with sharing class EmailTemplateTaskWhoDataController {
    public Id attrTaskWhoId {get; set;}
    public String attrListOfFieldApiNames {get; set;}
    public String attrListOfFieldLabels {get; set;}
    private String queryStr = '';
    
    public String getDataDisplayInHtml()
    {
        try
        {
            String rtnVal = '';
            
        	// Make sure WhoId is not blank and we have a list of field API names
            if (attrTaskWhoId != null && String.isNotBlank(attrListOfFieldApiNames))
            {
                // Check whether the WhoId is Contact, Lead, or User object
                String objectName = String.valueOf(this.attrTaskWhoId.getSobjectType());
                
                // As we are doing dynamic query, as a best practice, we want to at least limit the object we accept
                Set<String> allowedObject = new Set<String> {'Contact','Lead','User','Account'};

                if (allowedObject.contains(objectName))
                {
                    this.queryStr = 'SELECT ' + attrListOfFieldApiNames + ' FROM ' + objectName  + ' WHERE Id = \'' + attrTaskWhoId + '\' LIMIT 1';
                    
                    Map<String, Object> fieldToValue = new Map<String, Object>();
                    
                    List<SObject> sObjs = Database.query(this.queryStr);
                    
                    if (sObjs != null && !sObjs.isEmpty())
                    {
                        SObject sObj = sObjs[0];
                        
                        List<String> fieldNames = attrListOfFieldApiNames.split(','); // Parse the Field API Names
                        List<String> fieldLabels = attrListOfFieldLabels.split(','); // Parse the Field Labels
                        
                        Map<String, String> fieldNameToLabelMap = new Map<String, String>();
                        
                        for (Integer i = 0; i < fieldNames.size(); i++)
                        {
                            String fieldLabel = '';
                            
                            if (fieldLabels.size() > i && String.isNotBlank(fieldLabels.get(i)))
                            {
                                fieldLabel = fieldLabels.get(i);
                        	}
                            
                            fieldNameToLabelMap.put(fieldNames.get(i), fieldLabel);
                        }

                        Integer idx = 0;
                        
                        for (String fieldNameWithSObj : fieldNameToLabelMap.keySet())
                        {
                            idx++;
                            
                            SObject baseObject;
                            
                            if (String.isNotBlank(fieldNameWithSObj))
                            {
                                baseObject = sobj;
                                
                                // Parse the Field API Name by dot so that we can get the related object one by one
                                List<String> relSObjs = fieldNameWithSObj.split('\\.');
                                
                                // Loop through the related objects
                                for (Integer i = 0; i < relSObjs.size() - 1; i++) // We use size() - 1 because the last one is the field name, not the object name
                                {
                                    String relSObj = relSObjs.get(i);
                                    baseObject = baseObject.getSobject(relSObj);
                                }
                                
                                // Last one is the field name
                                String fieldName = relSObjs.get(relSObjs.size() - 1);
                                
                                String displayFieldLabel = String.isNotBlank(fieldNameToLabelMap.get(fieldNameWithSObj)) ? fieldNameToLabelMap.get(fieldNameWithSObj) : fieldNameWithSObj;
                                String displayFieldValue = String.isNotBlank(String.valueOf(baseObject.get(fieldName))) ? String.valueOf(baseObject.get(fieldName)) : '';
                                
                                rtnVal += '<span class="fld-' + idx + '"><div class="taskWhoFieldSet"><span class="taskWhoFieldName">' + displayFieldLabel.trim() + ': </span><span class="taskWhoFieldValue">' + displayFieldValue.trim() + '</span></div></span>';
                            }
                        }
                    }
                }
            }
            else
            {
                return '';
            }
            
            return rtnVal;
        }
        catch (Exception ex)
        {
            /*
            String errorMessage = 'EmailTemplateTaskWhoDataController returns an error: ' + ex.getMessage() + '\n' + ex.getStackTraceString() + '\n\nWith Query String: \n' + queryStr + '\n\n';

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Error in EmailTemplateTaskWhoDataController');
            email.setPlainTextBody(errorMessage);
            email.setSaveAsActivity(false);
            email.setToAddresses(new List<String>{'brian.chung@concur.com'});
            List<Messaging.SendEmailResult> sendEmailResults = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
			*/
            
            return null;
        }
    }
}