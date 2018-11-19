/**********************************************************************
 名    称：ImportController
 目    的：销售线索导入
 作    者：chencai
 创建日期：2018-9-17
 修 改 人：
 修改日期：
 修改原因：
 备    注：
 **********************************************************************/
global without sharing class ImportController {

    //导入模板路径
    public String leadUrl {GET; SET;}

    // 上传的数据
    public String output {GET; SET;}

    // 成功的表头信息
    public String tHeaderJson {GET; SET;}

    //上传文件对应的对象名
    public static String sourceName {GET; SET;}

    //上传文件名
    public static String importTable {GET; SET;}

    //上传数据报告
    public static ImportBean.ImportInfo iptInfo {GET; SET;}

    // 导入数据转换器
    public static ImportDataConvertor convertor {GET; SET;}

    // 导入模板名称
    public String importFile {GET; SET;}

    // 导入数量限制
    public String limitNumber {GET; SET;}

    // 导入的表头读取行数
    public Integer dataStartRow {GET; SET;}

    // 页面标头
    public String pageTitle {GET; SET;}

    // 允许部分更新
    public Boolean allowPartialUpdate {GET; SET;}

    public ImportController() {

        // 获得自定义数据设置名称
        sourceName = ApexPages.currentPage().getParameters().get('sourceName');

        if (String.isBlank(sourceName)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IMPORT_ERROR_PAGE_PARAMETER));
            return;
        }

        // 生成数据导入解析器
        convertor = new ImportDataConvertor(sourceName);

        // 获得导入模板文件(Excel)URL
        leadUrl = convertor.templateURL;

        // 生成表头信息
        tHeaderJson = JSON.serialize(convertor.headList);

        pageTitle = convertor.pageTitle;

        allowPartialUpdate = convertor.allowPartialUpdate;

        System.debug(LoggingLevel.INFO, '*** convertor.dataStartRow: ' + convertor.dataStartRow);

        dataStartRow = Integer.valueOf(convertor.dataStartRow);

        limitNumber = String.format(Label.IMPORT_LIMITNUMBER, new List<String>{String.valueOf(convertor.limitNumber)});

        System.debug(LoggingLevel.INFO, '*** tHeaderJson: ' + tHeaderJson);
    }

    /*
        方法名: upload
        功能说明:初步解析文件：判断导入表是否正确，以及数量是否超额
        参数说明：selected 选择的操作类型(更新，删除，导入); sourceName 对象名; importTable 上传文件名; PrentId 父对象Id; output 上传的数据;
        返回值：String
    */
    @RemoteAction 
    global static String upload(String sourceName, String importTable, String output) {

        System.debug(LoggingLevel.INFO, '*** output: ' + output);

        // 生成数据导入解析器
        ImportDataConvertor convertor = new ImportDataConvertor(sourceName);

        //初步解析文件：判断导入表是否正确，以及数量是否超额
        ImportBean.ImportInfo iptInfo  = new ImportBean.ImportInfo();
        if (output == null) {
            iptInfo.errMsg = Label.IMPORT_EMPTY;
            return JSON.serialize(iptInfo);
        }

        try {
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(output);

            List<Object> jsonList;

            if (jsonMap.size() > 0) {

                jsonList = (List<Object>)jsonMap.values()[0];

            } else if (jsonMap == null || jsonMap.size() == 0) {

                iptInfo  = new ImportBean.ImportInfo();
                iptInfo.errMsg = Label.FILE_NULL_DATA;
                return JSON.serialize(iptInfo);

            } else {

                iptInfo  = new ImportBean.ImportInfo();
                iptInfo.errMsg = String.format(Label.FIND_NOT_SHEET, new List<String>{importTable});
                return JSON.serialize(iptInfo);

            }

            if (jsonList == null || jsonList.size() <= 1) {
                iptInfo  = new ImportBean.ImportInfo();
                iptInfo.errMsg = Label.SHEET_NOT_DATA;
                return JSON.serialize(iptInfo);
            }

            if (jsonList.size() >= convertor.LimitNumber) {

                //CRC导入如果数量大于1000条
                iptInfo  = new ImportBean.ImportInfo();
                iptInfo.errMsg = String.format(Label.OVER_LINE_LIMIT, new List<String>{String.valueOf(convertor.LimitNumber)});
                return JSON.serialize(iptInfo);
            }

            // 导入文件解析并进行逻辑处理后，输出程序验证的错误结果，并把正确的部分获得出来
            iptInfo = convertor.Convert(jsonList);

        } catch(Exception e) {
            System.debug(e.getMessage() + '[Error Line: ' + e.getLineNumber() + '] ' + e.getStackTraceString());
            iptInfo  = new ImportBean.ImportInfo();
            iptInfo.errMsg = String.format(Label.IMPORT_SYSTEM_ABNORMALITY, new List<String>{e.getMessage(), String.valueOf(e.getLineNumber())});
            return JSON.serialize(iptInfo);
        }

        return JSON.serialize(iptInfo);
    }

    /*
        方法名: Save
        功能说明:调用保存方法
        参数说明：sucessDataMap 成功的数据; sourceName 资源名; importTable 上传文件名; sucessIptInfo 成功的组合信息;
        返回值：String
    */
    @RemoteAction 
    global static String Save(String sucessDataMap, String sucessIptInfo, String sourceName) {

        // 生成数据导入解析器
        ImportDataConvertor convertor = new ImportDataConvertor(sourceName);

        System.debug(LoggingLevel.INFO, '*** sucessDataMap: ' + sucessDataMap);
        System.debug(LoggingLevel.INFO, '*** sucessIptInfo: ' + sucessIptInfo);
        System.debug(LoggingLevel.INFO, '*** sourceName: ' + sourceName);

        List<ImportBean.Info> successList = (List<ImportBean.Info>)JSON.deserialize(sucessIptInfo, List<ImportBean.Info>.class);

        Set<Integer> successIndexSet = new Set<Integer>();

        for (ImportBean.Info info: successList) {
            successIndexSet.add(info.rowIndex);
        }

        System.debug(LoggingLevel.INFO, '*** successList: ' + successList);

        Map<String, Object> sucessMap = (Map<String,Object>)JSON.deserializeUntyped(sucessDataMap);

        Map<String, Map<Integer, Sobject>> dataMap = new Map<String, Map<Integer, Sobject>>();

        for (String objName : sucessMap.keySet()) {

            Map<Integer, Sobject> sobjectMap = new Map<Integer, Sobject>();
            Map<String, Object> objMap = (Map<String, Object>)sucessMap.get(objName);
            Map<Integer, Sobject> dataGroupMap = new Map<Integer, Sobject>();

            System.debug(LoggingLevel.INFO, '*** objName: ' + objName);

            for (String index : objMap.keySet()) {
                Map<String, Object> lineDataMap = (Map<String, Object>)objMap.get(index);
                Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objName);
                Sobject sobj = convertType.newSObject();

                System.debug(LoggingLevel.INFO, '***lineDataMap : ' + lineDataMap);

                for (String fieldName : lineDataMap.keySet()) {
                    if (fieldName != 'attributes') {
                        sobj.put(fieldName,lineDataMap.get(fieldName));
                    }
                }
                if (successIndexSet.contains(Integer.valueOf(index))) {
                    dataGroupMap.put(Integer.valueOf(index), sobj);
                }
            }
            if (dataGroupMap != null && dataGroupMap.size() > 0) {
                dataMap.put(objName,dataGroupMap);
            }
        }

        System.debug(LoggingLevel.INFO, '*** dataMap: ' + dataMap );

        ImportBean.ImportInfo iptInfo = new ImportBean.ImportInfo();

        // 导入文件解析并进行逻辑处理后，输出程序验证的错误结果，并把正确的部分获得出来
        if (dataMap != null && dataMap.size() > 0) {
            iptInfo = convertor.ImportDML(dataMap, successList);
        }

        System.debug(LoggingLevel.INFO, '*** iptInfo.errorList(Save): ' + iptInfo.errorList);

        return JSON.serialize(iptInfo);
    }
}