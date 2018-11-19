/**********************************************************************
 名    称：UniquenessCheckBean
 目    的：构造返回的重复信息
 作    者：chencai
 创建日期：2018-9-27
 修 改 人：
 修改日期：
 修改原因：
 备    注：
 **********************************************************************/

public without sharing class UniquenessCheckBean {
    /*
        内部类名: duplicateInfo
        说明: 重复信息整合
    */

    public class duplicateInfo {
        // 客户或线索所有人全名
        public String ownerName ;

        // 客户或线索名称
        public String name ;

        // 重复信息
        public String duplicateMsg ;

        // 重复的线索信息
        public Lead dupLead ;

        // 重复的联系人信息
        public Contact dupContact ;

        // 是否允许保存
        public Boolean canSave ;

        // 重复记录Id
        public Id dupId ;

        public Id leadId ;

        public duplicateInfo(String ownerName, String name, String duplicateMsg, Lead dupLead, Contact dupContact, Boolean canSave, Id dupId, Id leadId){
            this.ownerName = ownerName;
            this.name = name;
            this.duplicateMsg = duplicateMsg;
            this.dupLead = dupLead;
            this.dupContact = dupContact;
            this.canSave = canSave;
            this.dupId = dupId;
            this.leadId = leadId;
        }
    }

    /*
        内部类名: importDupInfo
        说明: 导入重复信息整合
    */
    public class importDupInfo {
        // 行数
        public Integer index;

        // 重复信息
        public String duplicateMsg;

        public importDupInfo(Integer index, String duplicateMsg){
            this.index = index;
            this.duplicateMsg = duplicateMsg;
        }
    }
}