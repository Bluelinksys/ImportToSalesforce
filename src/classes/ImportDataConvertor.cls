/**********************************************************************
 名    称：ImportDataConvertor
 目    的：导入映射类
 作    者：chencai
 创建日期：2018-9-17
 修 改 人：
 修改日期：
 修改原因：
 备    注：
 **********************************************************************/
public without sharing class ImportDataConvertor {

    // 自定义设置对象
    public Excel_Import_Config__mdt importConfig {GET; SET;}

    // 列映射表头关系
    public Map<String, String> importColumnsMap {GET; SET;}

    // 列映射字段集合
    public Map<String, String> importFieldsMap {GET; SET;}

    //错误输出结构
    public ImportBean.ImportInfo exportInfo {GET; SET;}

    // 基础设置
    public Map<String, Object> baseMap {GET; SET;}

    // Excel中数据开始行位置
    public Integer dataStartRow {GET; SET;}

    // Excel中表头所在行位置
    public Integer headerRow {GET; SET;}

    // 允许数据部分更新到数据库
    public Boolean allowPartialUpdate {GET; SET;}

    // 下载模板URL
    public String templateURL {GET; SET;}

    // 表头
    public List<ImportBean.TableKey> headList {GET; SET;}

    // 页面显示标题头
    public String pageTitle {GET; SET;}

    // 单次导入数量限制
    public Integer limitNumber {GET; SET;}

    // 列映射字段类型集合
    Map<String, String> importDataTypeMap;

    //获得下拉列表字段以及对应值
    Map<String, Map<String, Map<String, String>>> pickValuesMap;

    //导入渠道
    String sourceName;

    // 用于记录已进入执行DML操作的sobject，在Excel中对应行数的错误信息
    Map<Integer, String> errinfoMap;

    // 列映射字段类型集合必填字段
    Set<String> importRequriedSet;

    // 列映射对象字段映射关系
    Map<String, Set<String>> importSobjectColumnMap;

    // 对象查找关系
    Map<String, Map<String, String>> importLookupRelationalMap;

    // 字段查找关系
    Map<String, Map<String, String>> importLookupFieldMap;

    // 字段查找关系原始值
    Map<String, Set<String>> importLookupFieldValueMap;

    // Lookup字段查找结果
    Map<String, Map<String, String>> lookupFieldResultMap;

    // 数据保存顺序
    Set<String> importSaveOrderSet;

    // 记录类型Map，key-对象名称，value-记录类型DeveloperName
    Map<String, String> recordTypeMap;

    // 自定义验证类名
    String validateClassName;

    /*
        构造函数
        功能说明: 获取导入列和业务字段的Mapping关系
        参数说明：渠道类型
    */
    public ImportDataConvertor(String sourceName) {

        this.sourceName = sourceName;
        this.exportInfo = new ImportBean.ImportInfo();
        this.errinfoMap = new Map<Integer, String>();
        this.dataStartRow = 1;
        this.headerRow = 0;
        this.allowPartialUpdate = true;
        this.importLookupFieldValueMap = new Map<String, Set<String>>();
        this.lookupFieldResultMap = new Map<String, Map<String, String>>();

        // 获取导入表对应的元数据设置
        this.importConfig =  ImportUtility.getImportConfig(sourceName);

        // 记录类型将集合
        this.recordTypeMap = new Map<String, String>();

        // 基础设置
        this.baseMap = (Map<String, Object>) JSON.deserializeUntyped(importConfig.Base_Config__c);

        // 下载模板URL
        this.templateURL = PageReference.forResource(this.importConfig.ResourceZipName__c, '').getUrl();

        // 页面显示标题头
        this.pageTitle = this.importConfig.Page_Title__c;

        // 单次导入数量限制
        this.limitNumber = Integer.valueOf(this.importConfig.Limit_Number__c);

        // 自定义验证类名
        this.validateClassName = this.importConfig.validate_Class__c;

        if (baseMap != null && baseMap.size() > 0) {
            for (String configItemName : baseMap.keySet()) {
                if (configItemName == 'RecordType') {
                    Map<String, Object> recordSetMap = (Map<String, Object>)baseMap.get(configItemName);
                    for (String sobjectName : recordSetMap.keySet()) {
                        String recordDevName = String.valueOf(recordSetMap.get(sobjectName));
                        String recordId = ImportUtility.getRecordTypeId(recordDevName, sobjectName);
                        recordTypeMap.put(sobjectName, recordId);
                    }
                } else if (configItemName == 'StartRow') {
                    this.dataStartRow = Integer.valueOf(baseMap.get(configItemName));
                } else if (configItemName == 'HeaderRow') {
                    this.headerRow = Integer.valueOf(baseMap.get(configItemName));
                } else if (configItemName == 'AllowPartialUpdate') {
                    this.allowPartialUpdate = Boolean.valueOf(String.valueOf(baseMap.get(configItemName)).trim().toLowerCase());
                }
            }
        }
        System.debug(LoggingLevel.INFO, '*** dataStartRow: ' + dataStartRow);

        // 数据类型映射关系
        this.importDataTypeMap = (Map<String, String>) JSON.deserialize(importConfig.DataType_Mapping__c, Map<String, String>.class);

        // 字段映射关系
        this.importFieldsMap = (Map<String, String>) JSON.deserialize(importConfig.Fields_Mapping__c, Map<String, String>.class);

        // 对象和列对应关系
        this.importSobjectColumnMap = (Map<String, Set<String>>) JSON.deserialize(importConfig.Sobject_Columns_Mapping__c, Map<String, Set<String>>.class);

        // 列名映射关系
        this.importColumnsMap = (Map<String, String>)JSON.deserialize(importConfig.Columns_Mapping__c, Map<String, String>.class);

        // 必填字段集合
        this.importRequriedSet = (Set<String>)JSON.deserialize(importConfig.Fields_Required__c, Set<String>.class);

        // 对象保存顺序
        this.importSaveOrderSet = (Set<String>)JSON.deserialize(importConfig.Save_Ordering__c, Set<String>.class);

        // 对象查找关系设置
        this.importLookupRelationalMap = new Map<String, Map<String, String>>();
        if (String.isNotBlank(importConfig.Lookup_Relational_Mapping__c)) {
            this.importLookupRelationalMap = (Map<String, Map<String, String>>)JSON.deserialize(importConfig.Lookup_Relational_Mapping__c, Map<String, Map<String, String>>.class);
        }

        // 字段查找关系
        this.importLookupFieldMap = new Map<String, Map<String, String>>();
        if (String.isNotBlank(importConfig.Lookup_Field_Mapping__c)) {
            this.importLookupFieldMap = (Map<String, Map<String, String>>)JSON.deserialize(importConfig.Lookup_Field_Mapping__c, Map<String, Map<String, String>>.class);
        }

        // 表头
        this.headList = new List<ImportBean.TableKey>();
        for (String fieldName : this.importColumnsMap.keySet()) {
            ImportBean.TableKey key = new ImportBean.TableKey();
            key.title = fieldName;
            key.field = String.valueOf(this.importColumnsMap.get(fieldName));
            this.headList.add(key);
        }

        // Picklist字段集合Map<key-对象名,value-List<字段API>>
        Map<String, List<String>> picklistMap = new Map<String, List<String>>();

        // 得到对象及对应的Picklist字段集合
        for (String sobjectApiName : this.importSobjectColumnMap.keySet()) {
            for (String fieldName : this.importSobjectColumnMap.get(sobjectApiName)) {
                if (this.importDataTypeMap.containsKey(fieldName) && 
                    this.importFieldsMap.containsKey(fieldName) && 
                    (this.importDataTypeMap.get(fieldName) == 'Picklist' || 
                     this.importDataTypeMap.get(fieldName) == 'MultiPicklist')) {

                    if (picklistMap.containsKey(sobjectApiName)) {
                        picklistMap.get(sobjectApiName).add(this.importFieldsMap.get(fieldName));
                    } else {
                        picklistMap.put(sobjectApiName, new List<String>{this.importFieldsMap.get(fieldName)});
                    }

                }
            }
        }

        // 通过Schema获取选项列表值
        this.pickValuesMap = ImportUtility.getSchemaPickValuesMap(picklistMap);
    }

     /*
        方 法 名: Convert
        功能说明: 导入文件解析并进行逻辑处理后，输出程序验证的错误结果，并把正确的部分获得出来，进行第二轮的数据库校验。
        参数说明：jsonList - Excel数据行集合
        返 回 值：ImportInfo - 
     */
    public ImportBean.ImportInfo Convert(List<Object> jsonList) {

        Map<Integer, Map<String, String>> kmiDataMap = new Map<Integer, Map<String, String>> ();
        System.debug(LoggingLevel.INFO, '*** jsonList: ' + jsonList.size());
        System.debug(LoggingLevel.INFO, '*** dataStartRow: ' + dataStartRow);

        // Map<key-对象名, valueMap<key-行数,value-对象实例数据>>
        Map<String, Map<Integer, SObject>> excelDataMap = new Map<String, Map<Integer, SObject>>();
        for (String sobjectApiName : this.importSaveOrderSet) {
            excelDataMap.put(sobjectApiName, new Map<Integer, SObject>());
        }

        // 读取数据并根据配置文件检测数据完整性
        for (Integer i = dataStartRow; i < jsonList.size(); i++) {

            // 读取一行
            Map<String, Object> resultsMap = (Map<String, Object>) jsonList[i];
            Map<String, String> rowDataMap = new Map<String, String>();
            ImportBean.Info info = new ImportBean.Info(rowDataMap, i + 1, false, '', '');

            for (String fieldName : importFieldsMap.keySet()) {

                if (resultsMap.get(this.importColumnsMap.get(fieldName)) != null) {
                    String fieldValue = String.valueOf(resultsMap.get(this.importColumnsMap.get(fieldName))).trim();
                    rowDataMap.put(fieldName, fieldValue);
                    String err = this.checkFieldInfo(fieldName, fieldValue);
                    if (String.isNotBlank(err)) {
                        info.isError = true;
                        info.errorField += fieldName + '; ';
                        info.errorMessage += err;
                    }
                } else {
                    rowDataMap.put(fieldName, '');
                    if (this.importRequriedSet.contains(fieldName)) {
                        info.isError = true;
                        info.errorField += fieldName + '; ';
                        info.errorMessage += String.format(Label.REQURIED_DELETION, new List<String>{fieldName});
                    }
                }
            }

            // 对无错误数据创建对象实例
            if (info.isError == false) {
                this.exportInfo.sucessList.add(info);
                for (String sobjectApiName : this.importSaveOrderSet) {
                    Schema.SObjectType convertType = Schema.getGlobalDescribe().get(sobjectApiName);
                    Sobject sObj = convertType.newSObject();
                    if (this.recordTypeMap.containsKey(sobjectApiName)) {
                        sObj.put('RecordTypeId', this.recordTypeMap.get(sobjectApiName));
                    }

                    for (String fieldName : rowDataMap.keySet()) {
                        if (this.importSobjectColumnMap.get(sobjectApiName).contains(fieldName)) {
                            sObj.put(this.importFieldsMap.get(fieldName), this.dataConvert(sobjectApiName, fieldName, rowDataMap.get(fieldName)));
                        }
                    }
                    excelDataMap.get(sobjectApiName).put(i + 1, sObj);
                }
            } else {
                this.exportInfo.errorList.add(info);
            }
        }

        this.exportInfo.sobjectMap.putAll(excelDataMap);

        // 查询出Lookup对应的数据
        if (this.importLookupFieldValueMap.size() > 0) {
            for (String field : importLookupFieldValueMap.keySet()) {

                // 如果有配置
                if (this.importLookupFieldMap.containsKey(field)) {
                    Map<String, String> lookupConfig = importLookupFieldMap.get(field);
                    String objName = lookupConfig.get('SObject');
                    String currFieldName = lookupConfig.get('Field');
                    String currFieldType  = lookupConfig.get('FieldType');

                    Object valueSet = this.converDataType(this.importLookupFieldValueMap.get(field), currFieldType);
                    String sql = 'SELECT Id,' + currFieldName + ' FROM ' + objName + ' WHERE ' + currFieldName + ' IN :valueSet';
                    List<SObject> objList = Database.query(sql);
                    Map<String, String> lookupValueMap;
                    if (this.lookupFieldResultMap.containsKey(field)) {
                        lookupValueMap = this.lookupFieldResultMap.get(field);
                    } else {
                        lookupValueMap = new Map<String, String>();
                        this.lookupFieldResultMap.put(field, lookupValueMap);
                    }

                    // 记录要导入的Lookup字段值对应的Lookup Id
                    for (SObject obj : objList) {
                        lookupValueMap.put(String.valueOf(obj.get(currFieldName)), String.valueOf(obj.get('Id')));
                    }

                    System.debug(LoggingLevel.INFO, '*** lookupValueMap: ' + lookupValueMap);

                } else {
                    throw new ImportUtility.ImportUtilityException(String.format(Label.IMPORT_CONFIG_NOT_EXIST, new List<String>{'Lookup' + field}));
                }
            }
        }

        // 对Lookup字段设置值
        for (String sobjectApiName : this.importSaveOrderSet) {
            Map<Integer, SObject> row = excelDataMap.get(sobjectApiName);
            for (String fieldName : this.importDataTypeMap.keySet()){
                if (this.importDataTypeMap.get(fieldName).trim().toLowerCase() == 'lookup') {
                    String fieldApiName = this.importFieldsMap.get(fieldName);
                    for (Integer rowIndex : row.keySet()) {
                        SObject obj = row.get(rowIndex);
                        Map<String, Object> originalData = (Map<String, Object>)jsonList[rowIndex - 1];
                        String originalValue = String.valueOf(originalData.get(this.importColumnsMap.get(fieldName))).trim();

                        System.debug(LoggingLevel.INFO, '*** originalValue: ' + originalValue);

                        obj.put(fieldApiName, this.lookupFieldResultMap.get(fieldName).get(originalValue));
                    }
                }
            }
        }

        // 调用自定义验证类验证数据的正确性
        if (String.isNotBlank(this.validateClassName)) {
            List<ImportBean.Info> validateResultList = this.validate(this.validateClassName, excelDataMap);
            if (validateResultList != null && validateResultList.size() > 0) {
                this.exportInfo.errorList.addAll(validateResultList);
                if ( this.exportInfo.sucessList != null &&  this.exportInfo.sucessList.size() > 0) {
                    for (ImportBean.Info info : validateResultList) {
                        for (Integer i = 0 ;i < this.exportInfo.sucessList.size() ; i++) {
                            ImportBean.Info sucessinfo = this.exportInfo.sucessList.get(i);
                            if ( info.rowIndex == sucessinfo.rowIndex ) {
                                exportInfo.sucessList.remove(i);
                            }
                        }
                    }
                }
            }
        }

        return this.exportInfo;
    }

    /*
        目的： 字段数据完整性检测
        参数： fieldName - 字段名称（Label）
               fieldValue - 字段值 
        返回： 无错误返回空('')，否则返回错误信息
    */
    private List<Object> converDataType(Set<String> dataList, String dataTypeName) {
        List<Object> valueList;
        switch on dataTypeName.toLowerCase() {
            when 'decimal','numeric','integer' {
                valueList = new List<Decimal>();
            }

            when else {
                valueList = new List<String>();
            }
        }

        for (String value : dataList) {
            Object val;
            switch on dataTypeName.toLowerCase() {

                when 'decimal','numeric','integer' {
                    val = Decimal.valueOf(value);
                }

                when else {
                    val = value;
                }
            }
            valueList.add(val);
        }

        return valueList;
    }

    /*
        目的： 字段数据完整性检测
        参数： fieldName - 字段名称（Label）
               fieldValue - 字段值 
        返回： 无错误返回空('')，否则返回错误信息
    */
    private String checkFieldInfo(String fieldName, String fieldValue) {
        String errorMessage = '';
        for (String sObjectApiName : this.importSaveOrderSet) {
            if (this.importSobjectColumnMap.get(sObjectApiName).contains(fieldName)){

                // 字段数据检验
                switch on this.importDataTypeMap.get(fieldName).toLowerCase() {
                    when 'picklist' {
                        errorMessage = ImportUtility.checkPicklist(fieldName, fieldValue, this.pickValuesMap.get(sObjectApiName).get(this.importFieldsMap.get(fieldName)));
                    }

                    when 'multipicklist' {
                        System.debug(LoggingLevel.INFO, '*** fieldName: ' + fieldName);
                        System.debug(LoggingLevel.INFO, '*** fieldValue: ' + fieldValue);
                        errorMessage = ImportUtility.checkMultiPicklist(fieldName, fieldValue, this.pickValuesMap.get(sObjectApiName).get(this.importFieldsMap.get(fieldName)));
                    }

                    when 'date' {
                        errorMessage = ImportUtility.checkDate(fieldName, fieldValue);
                    }

                    when 'time' {
                        errorMessage = ImportUtility.checkTime(fieldName, fieldValue);
                    }

                    when 'datetime' {
                        errorMessage = ImportUtility.checkDatetime(fieldName, fieldValue);
                    }

                    when 'integer','decimal','numeric' {
                        errorMessage = ImportUtility.checkNumber(fieldName, fieldValue);
                    }

                    when 'email' {
                        errorMessage = ImportUtility.checkEmailFormat(fieldName, fieldValue);
                    }

                    when 'boolean' {
                        errorMessage = ImportUtility.checkBoolean(fieldName, fieldValue);
                    }

                    // 如果是Lookup字段，先不处理，后面在做验证
                    when 'lookup' {

                        System.debug(LoggingLevel.INFO, '*** checkFieldInfo(fieldName, fieldValue): ' + fieldName + '-' + fieldValue);

                        if (importLookupFieldValueMap.containsKey(fieldName)) {
                            importLookupFieldValueMap.get(fieldName).add(fieldValue);
                        } else {
                            importLookupFieldValueMap.put(fieldName, new Set<String>{fieldValue});
                        }
                    }
                }
            }
        }

        return errorMessage;
    }

    /*
        数据转换
    */
    private Object dataConvert(String sobjectApiName, String fieldName, String fieldValue) {
        Object obj = null;
        if (!String.isBlank(fieldValue)) {
            switch on this.importDataTypeMap.get(fieldName).toLowerCase() {
                when 'picklist' {
                    obj = this.pickValuesMap.get(sObjectApiName).get(this.importFieldsMap.get(fieldName)).get(fieldValue);
                }

                when 'multipicklist' {
                    String[] fieldValueSet = fieldValue.split(';');
                    String multiPicklistValue = '';
                    for (String fieldLabel : fieldValueSet) {
                        multiPicklistValue += this.pickValuesMap.get(sObjectApiName).get(this.importFieldsMap.get(fieldName)).get(fieldLabel) + ';';
                    }
                    obj = multiPicklistValue;
                    System.debug(LoggingLevel.INFO, '*** obj: ' + obj);
                }

                when 'string','text','email' {
                    obj = fieldValue;
                }

                when 'date' {
                    obj = Date.valueOf(fieldValue);
                }

                when 'time' {
                    List<String> times = fieldValue.replace('：',':').split(':');
                    Integer HH = Integer.valueOf(times[0]);
                    Integer mm = times.size() > 1 ? Integer.valueOf(times[1]) : 0;
                    Integer ss = times.size() > 2 ? Integer.valueOf(times[2]) : 0;
                    obj = Time.newInstance(HH, mm, ss, 0);
                }

                when 'datetime' {
                    TimeZone tz = UserInfo.getTimeZone();
                    Datetime dt = Datetime.valueOf(fieldValue);
                    Integer offset = tz.getOffset(dt);
                    Integer h = offset / (1000 * 60 * 60);
                    obj = dt.addHours(h);
                }

                when 'integer' {
                    obj = Integer.valueOf(fieldValue);
                }

                when 'decimal','numeric' {
                    obj = Decimal.valueOf(fieldValue);
                }

                when 'boolean' {
                    obj = Boolean.valueOf(fieldValue);
                }

                when 'lookup' {
                    obj = null;
                }
            }
        }

        return obj;
    }

    /*
      方法名: KMI_DML
      功能说明: 将数据插入/更新至数据库中，并获取插入/更新失败列表
      参数说明：DMLOption - Map<Integer, Sobject>>
               excelDatas - List<ImportBean.Info>
      返回值：ImportBean.ImportIn
     */
    public ImportBean.ImportInfo ImportDML(Map<String, Map<Integer, Sobject>> DMLOption, List<ImportBean.Info> excelDatas) {

        SavePoint sp = Database.setSavepoint();

        // 获取成功数据的行号
        List<Integer> indexList = new List<Integer>();
        indexList.addAll(DMLOption.values()[0].keySet());

        //用于记录已进入执行DML操作的sobject，在Excel中对应行数
        Map<Integer, Integer> indexMap = new Map<Integer, Integer>();

        System.debug(LoggingLevel.INFO, '*** ImportDML - indexList: ' + JSON.serializePretty(indexList));
        System.debug(LoggingLevel.INFO, '*** ImportDML - excelDatas: ' + JSON.serializePretty(excelDatas));

        for (Integer i = 0; i < indexList.size(); i++) {
            indexMap.put(i, indexList.get(i));
            errinfoMap.put(indexList.get(i), '');
        }

        Boolean isRollBack = false;
        try {

            Integer insIndex = 0;

            for (String sObjectApiName : this.importSaveOrderSet) {

                List<Database.SaveResult> saveResult;

                System.debug(LoggingLevel.INFO, '*** this.allowPartialUpdate: ' + this.allowPartialUpdate);

                // 对象插入顺序,第一个直接插入，后面的对象赋前一个对象的Id
                if (insIndex == 0 && DMLOption.containsKey(sObjectApiName)) {
                    saveResult = Database.insert(DMLOption.get(sObjectApiName).values(), !this.allowPartialUpdate);
                } else {
                    if (DMLOption.containsKey(sObjectApiName)) {
                        for (Integer index : DMLOption.get(sObjectApiName).keySet()) {
                            Sobject childSobject = DMLOption.get(sObjectApiName).get(index);
                            for (String lookupFieldName : this.importLookupRelationalMap.get(sObjectApiName).keySet()) {
                                Sobject parentSobject = DMLOption.get(this.importLookupRelationalMap.get(sObjectApiName).get(lookupFieldName)).get(index);
                                childSobject.put(lookupFieldName, parentSobject.get('Id'));
                            }
                        }
                        saveResult = Database.insert(DMLOption.get(sObjectApiName).values(), !this.allowPartialUpdate);
                    }
                }

                System.debug(LoggingLevel.INFO, '*** saveResult: ' + saveResult);

                // 解析DML操作结果
                Integer index  = 0;
                for (Database.SaveResult sr : saveResult) {
                    if (!sr.isSuccess()) {
                        String errStr = '';
                        for (Database.Error err : sr.getErrors()) {
                            String errText = err.getMessage() + '/' + err.getFields() + '/' + err.getStatusCode();
                            errStr += ImportUtility.DmlExceptionTranslator(errText) + '; ';
                        }

                        errinfoMap.put(indexMap.get(index), errStr);

                        if (!this.allowPartialUpdate) {
                            isRollBack = true;
                        }
                    }
                    index++;
                }

                insIndex++;
            }

            System.debug(LoggingLevel.INFO, '*** errinfoMap: ' + errinfoMap);

            // 整理错误数据
            for (ImportBean.Info info : excelDatas) {
                if (errinfoMap.containsKey(info.rowIndex) && String.isNotBlank(errinfoMap.get(info.rowIndex))) {
                    System.debug(LoggingLevel.INFO, '*** info.rowData: ' + info.rowData);
                    this.exportInfo.errorList.add(new ImportBean.Info(info.rowData, info.rowIndex, true, '', errinfoMap.get(info.rowIndex)));
                }
                if (errinfoMap.containsKey(info.rowIndex) && String.isBlank(errinfoMap.get(info.rowIndex))) {
                    this.exportInfo.sucessList.add(new ImportBean.Info(info.rowData, info.rowIndex, false, '', ''));
                }
            }

            if (isRollBack) {
                Database.rollback(sp);
            }

        } catch (Exception ex) {

            System.debug(LoggingLevel.INFO, '*** : ImportDML Error: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
            Database.rollback(sp);
        }

        if (this.exportInfo.errorList != null && this.exportInfo.errorList.size() > 0) {
            if (!this.allowPartialUpdate) {
                this.exportInfo.errMsg = Label.SAVE_OCCURED_ERROR;
            }
        }

        return this.exportInfo;
    }

    /*
        目的：自定义验证数据的正确性
        返回：如果有错，则返回错误信息数组，否则，返回空数组
    */
    private List<ImportBean.Info> validate(String className, Map<String, Map<Integer,Sobject>> sourceDataList) {

        Type t = Type.forName(className);
        ImportValidateInterface ivif = (ImportValidateInterface)t.newInstance();

        return ivif.validate(className, sourceDataList);
    }
}