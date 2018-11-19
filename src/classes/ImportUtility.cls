/**********************************************************************
 名    称：ImportUtility
 目    的：导入Excel数据工具类
 作    者：chencai
 创建日期：2018-9-17
 修 改 人：
 修改日期：
 修改原因：
 备    注：
 **********************************************************************/
public without sharing class ImportUtility {

    public class ImportUtilityException extends Exception{}

    /*
        方 法 名: getSchemaPickValuesMap
        功能说明: 获取对象的Picklist字段及其对应值
        参数说明： picklistMap 
                      key - 对象名
                      value - 选项列表字段集合
        返 回 值： Map<String, Map<String, Map<String, String>>> 
                  例：Map<objectName, Map<filedName, Map<label, api>>>
                      key - 对象名
                      value - 字段的和它的选项列表值
                          key - 字段名
                          value - 字段选项列表值集合(Label + API)
    */
    public static Map<String, Map<String, Map<String, String>>> getSchemaPickValuesMap(Map<String, List<String>> picklistMap) {
        Map<String, Map<String, Map<String, String>>> pickValuesMap = new Map<String, Map<String, Map<String, String>>>();

        // 得到对象列表
        List<String> objectName = new List<String>();
        objectName.addAll(picklistMap.keySet());

        System.debug(LoggingLevel.INFO, '*** objectName: ' + objectName);

        // 得到对象描述结果
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(objectName);

        for (Schema.DescribeSobjectResult sobjectDescribe : results) {

            // 字段选项列表值MAP
            Map<String, Map<String, String>> fieldMap = new Map<String, Map<String, String>>();

            for(String fieldName : picklistMap.get(sobjectDescribe.getName())) {

                // 选项列表值MAP
                Map<String, String> fieldValuesMap = new Map<String, String>();

                for (Schema.PicklistEntry pe : sobjectDescribe.fields.getMap().get(fieldName).getDescribe().getPickListValues()) {
                    fieldValuesMap.put(pe.getLabel(), pe.getValue());
                }

                fieldMap.put(fieldName, fieldValuesMap);
            }

            pickValuesMap.put(sobjectDescribe.getName(), fieldMap);
        }

        return pickValuesMap;
    }

    /*
        方 法 名: joinTwoText
        功能说明: 连接二个文本值
        参数说明： originalText - 原文本值
        返 回 值： newText - 要连接（增加）的新文本值
    */
    public static String joinTwoText(String originalText, String newText) {
        if (String.isBlank(originalText)) {
            return newText;
        } else if (String.isBlank(newText)) {
            return originalText;
        } else {
            return originalText + newText;
        }
    }

    /*
        方 法 名: dmlExceptionTranslator
        功能说明: 系统报错友好提醒
        参数说明： errorMsg - 错误信息
        返 回 值：
    */
    public static String dmlExceptionTranslator(String errorMsg) {
        if (errorMsg.contains('DUPLICATE_VALUE')) {
            return Label.DUPLICATE_VALUE;
        } 
        return errorMsg;
    }

    /*
        方 法 名: requiredFormat
        功能说明: 必填校验并输出错误
        参数说明：fieldName - 字段名
                 valStr - 字段值
        返 回 值：如果字段值为空，则返回错误信息，否则返回空
    */
    public static String requiredFormat(String fieldName, String valStr){
        if (String.isBlank(valStr)) {
            return String.format(Label.REQURIED_DELETION, new List<String>{fieldName});
        } else {
            return '';
        }
    }

    /*
        方 法 名: checkEmailFormat
        功能说明: 检验邮箱格式并输出错误
        参数说明：fieldName - 字段名
                 emlStr - Email格式字符串
        返 回 值：如果字段值不是正确的邮箱，则返回错误信息，否则返回空
    */
    public static String checkEmailFormat(String fieldName, String emlStr) {
        String emailFormat = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        if (!Pattern.matches(emailFormat, emlStr)) {
            return String.format(Label.INVALID_EMAIL, new List<String>{fieldName, emlStr});
        } else {
            return '';
        }
    }

    /*
        方法名: checkPicklist
        功能说明: 检验Picklist值并输出错误
        参数说明：fieldName - 字段名
                 pickStr - 选项列表值
                 vMap - 值集合
        返 回 值：如果字段值包含在值集合中，则返回空，否则返回错误信息
    */
    public static String checkPicklist(String fieldName, String pickStr, Map<String, String> vMap) {
        if (vMap != null && vMap.containsKey(pickStr)) {
            return '';
        } else {
            return String.format(Label.INVALID_PICKLIST, new List<String>{fieldName, pickStr});
        }
    }

    /*
        方法名: checkDate
        功能说明: 检验日期值并输出错误
        参数说明：fieldName - 字段名
                 dateStr - 日期字符串
        返 回 值：如果字段值是日期，则返回空，否则返回错误信息
    */
    public static String checkDate(String fieldName, String dateStr) {
        try {
            Date d = Date.valueOf(dateStr);
            return '';
        } catch(Exception ex) {
            return String.format(Label.INVALID_DATE, new List<String>{fieldName, dateStr});
        }
    }

    /*
        方法名: checkTime
        功能说明: 检验时间值并输出错误
        参数说明：fieldName - 字段名
                 dateStr - 日期字符串
        返 回 值：如果字段值是日期，则返回空，否则返回错误信息
    */
    public static String checkTime(String fieldName, String timeStr) {
        try {
            List<String> timeList = timeStr.replace('：', ':').split(':');
            if (timeList.size() > 2) {
                Time t = Time.newInstance(Integer.valueOf(timeList[0]), Integer.valueOf(timeList[1]), Integer.valueOf(timeList[2]), 0);
                return '';
            } else {
                return String.format(Label.IMPORT_INVALID_TIME, new List<String>{fieldName, timeStr});
            }
        } catch(Exception ex) {
            return String.format(Label.IMPORT_INVALID_TIME, new List<String>{fieldName, timeStr});
        }
    }

    /*
        方法名: checkBoolean
        功能说明: 检验布尔值并输出错误
        参数说明：fieldName - 字段名
                 boolStr - 字符串
        返 回 值：如果字段值可以转换为布尔值，则返回空，否则返回错误信息
    */
    public static String checkBoolean(String fieldName, String boolStr) {
        try {
            Date d = Date.valueOf(boolStr);
            return '';
        } catch(Exception ex) {
            return String.format(Label.INVALID_BOOLEAN, new List<String>{fieldName, boolStr});
        }
    }

    /*
        方法名: checkDatetime
        功能说明: 检验日期时间值并输出错误
        参数说明：fieldName - 字段名
                 datetimeStr - 选项列表值
        返 回 值：如果字段值是日期时间，则返回空，否则返回错误信息
    */
    public static String checkDatetime(String fieldName, String datetimeStr) {
        try {
            Datetime d = Datetime.valueOf(datetimeStr);
            return '';
        } catch(Exception ex) {
            return String.format(Label.INVALID_DATETIME, new List<String>{fieldName, datetimeStr});
        }
    }

    /*
        方法名: checkNumber
        功能说明: 检验数字值并输出错误
        参数说明：fieldName - 字段名
                 numberStr - 数字字符串
        返 回 值：如果是数字，则返回空，否则返回错误信息
    */
    public static String checkNumber(String fieldName, String numberStr) {
        try {
            Decimal d = Decimal.valueOf(numberStr);
            return '';
        } catch(Exception ex) {
            return String.format(Label.INVALID_NUMERIC, new List<String>{fieldName, numberStr});
        }
    }

    /*
        方法名: checkMultiPicklist
        功能说明: 检验MultiPicklist值并输出错误
        参数说明：fieldName - 字段名
                 pickStr - 选项列表值
                 vMap - 值集合
        返 回 值：如果字段值包含在值集合中，则返回空，否则返回错误信息
    */
    public static String checkMultiPicklist(String fieldName, String pickStr, Map<String, String> vMap) {
        if (String.isBlank(pickStr) || vMap == null) {
            return '';
        }

        List<String> pickStrList = new List<String>();
        pickStrList.addAll(pickStr.split(';'));

        for (String pickLabel : pickStrList) {
            if (!vMap.containsKey(pickLabel)) {
                return String.format(Label.INVALID_PICKLIST, new List<String>{fieldName, pickLabel});
            }
        }
        
        return '';
    }

    /*
        方 法 名: getComplexObjectMap
        功能说明: 通过复杂类型的外键ID查找相应的对象表，得到具体的对象记录
        参数说明： lookupFieldsMap<key-对象,List<Map<key-字段API,value-字段值>>>
        返 回 值： Map<String, Map<String, String>>
    */
    public static Map<String, Map<String, String>> getComplexObjectMap(Map<String,List<Map<String,String>>> lookupFieldsMap , Map<String,Object> relationFieldsMap) {
        Map<String, Map<String, String>> lookupValuesMap = new Map<String, Map<String, String>>();
        for (String objectName : lookupFieldsMap.keySet()) {
            
        }
        return lookupValuesMap;
    }

     /*
        目的：得到导入配置信息
        参数：导入配置开发名
        返回：Excel_Import_Config__mdt对象
    */
    public static Excel_Import_Config__mdt getImportConfig(String DeveloperName) {
        List<Excel_Import_Config__mdt> configList = [SELECT MasterLabel,
                                                            DeveloperName,
                                                            Columns_Mapping__c,
                                                            Base_Config__c,
                                                            Fields_Mapping__c,
                                                            Save_Ordering__c,
                                                            Sobject_Columns_Mapping__c,
                                                            Lookup_Relational_Mapping__c,
                                                            Fields_Required__c,
                                                            DataType_Mapping__c,
                                                            Limit_Number__c,
                                                            Page_Title__c,
                                                            Validate_Class__c,
                                                            ResourceZipName__c,
                                                            Lookup_Field_Mapping__c 
                                                     FROM Excel_Import_Config__mdt 
                                                     WHERE DeveloperName = :DeveloperName];
        if(configList.size() > 0) {
            return configList[0];
        } else {
            throw new ImportUtilityException(Label.IMPORT_CONFIG_DEVELOPER_NAME_NOT_EXIST);
        }
    }

    /*
        获取记录类型ID，
        参数:
            recordTypeName为developerName
            sObjectType是对象名称
    */
    public static Id getRecordTypeId(String recordTypeName, String sObjectType) {
        List<RecordType> recordTypeList = [SELECT Id, 
                                                  DeveloperName,
                                                  SobjectType,
                                                  Name 
                                           FROM RecordType
                                           WHERE DeveloperName = :recordTypeName 
                                           AND sObjectType = :sObjectType];
        if (recordTypeList.isEmpty()) {
            throw new ImportUtilityException(String.format(Label.RECORD_TYPE_NAME_NOT_EXIST, new List<String>{sObjectType, recordTypeName}));
        } else {
            return recordTypeList[0].Id;
        }
    }
}