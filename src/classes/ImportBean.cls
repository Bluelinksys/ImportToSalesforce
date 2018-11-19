/**********************************************************************
 名    称：ImportBean
 目    的：导入数据结构
 作    者：chencai
 创建日期：2018-9-17
 修 改 人：
 修改日期：
 修改原因：
 备    注：
 **********************************************************************/
public without sharing class ImportBean {
    /*
        内部类名: ImportInfo
        说明: 导入数据整合
    */
    public class ImportInfo {
        public String errMsg {GET; SET;}
        public Integer size {
            GET {
                return this.infoList.size();
            }
        }
        public Integer failed {
            GET {
                return this.errorList.size();
            }
        }
        public List<Info> infoList {GET; SET;}
        public List<Info> sucessList {GET; SET;}
        public List<Info> errorList {GET; SET;}
        public List<Info> duplicateList {GET; SET;}
        public Map<String, Map<Integer, Sobject>> sObjectMap {GET; SET;}

        public ImportInfo() {
            this.infoList = new List<Info>();
            this.sucessList = new List<Info>();
            this.errorList = new List<Info>(); 
            this.duplicateList = new List<Info>(); 
            this.sObjectMap = new Map<String, Map<Integer, Sobject>>();
        }
    }

    /*
        内部类名: Info
        说明: 组装excel数据信息
    */
    public class Info {
        public Map<String, String> rowData {GET; SET;}
        public Integer rowIndex {GET; SET;}
        public Boolean isError {GET; SET;}
        public Boolean isDuplicate {GET; SET;}
        public String errorField {GET; SET;}
        public String duplicateFiled {GET; SET;}
        public String errorMessage {GET; SET;}
        public List<duplicate> duplicateList {GET; SET;}

        public Info(Map<String, String> rowData, Integer rowIndex, Boolean isError, String errorField, String errorMessage) {
            this.rowData = rowData;
            this.rowIndex = rowIndex;
            this.isError = isError;
            this.errorField = errorField;
            this.errorMessage = errorMessage;
            this.duplicateList = new List<duplicate>();
        }
    }

    /*
        内部类名: duplicate
        说明: 导入数据重复的列信息
    */
    public class duplicate {
        public String duplicateMassage {GET; SET;}
        public String SobjectName {GET; SET;}
        public String phone {GET; SET;}
        public String mobilePhone {GET; SET;}
        public String qq {GET; SET;}
        public String wechat {GET; SET;}
        public String sobjectId {GET; SET;}
        public Boolean isSelect {GET; SET;}
    }

    /*
        内部类名: ErrMsg
        说明: 导入数据错误的列信息
    */
    public class ErrMsg{
        public String errorField;
        public String errorMessage ;
    }

    /*
        内部类名: Selected
        说明: 选中的信息
    */
    public class Selected {
        public Integer Counter {GET; SET;}
        public String SelectId {GET; SET;}
    }

    /*
        内部类名: TableKey
        说明: 组装成功信息的表头信息
    */
    public class TableKey {
        public String title {GET; SET;}
        public String field {GET; SET;}
    }
}