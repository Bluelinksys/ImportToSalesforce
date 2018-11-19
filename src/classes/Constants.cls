public without sharing class Constants {
    public Constants() {

    }

    // 角色部门
    public static final String DEPARTMENT_SALE = Label.DEPARTMENT_SALE;
    public static final String DEPARTMENT_PURCHASE = Label.DEPARTMENT_PURCHASE;

    // 客户记录类型
    public static final String ACCOUNT_RECORDTYPE_RELATED = 'Related';
    public static final String ACCOUNT_RECORDTYPE_UNRELATED = 'FormalCustom';
    public static final String ACCOUNT_RECORDTYPE_PAYER = 'Payer';
    public static final String ACCOUNT_RECORDTYPE_SUPPLIER = 'FormalSupplier';
    public static final String ACCOUNT_RECORDTYPE_TICKETHOLDER = 'TicketHolder';
    public static final String ACCOUNT_RECORDTYPE_SHIPTOPARTY = 'ShipToParty';

    // 潜在客户记录类型
    public static final String LEAD_RECORDTYPE_SALES = 'Sales';
    public static final String LEAD_RECORDTYPE_SUPPLIER = 'Supplier';

    // OA审批类型
    public static final String OA_SUPPLY_CONVERT = '潜在供应商转换';
    public static final String OA_LEAD_CONVERT = '潜在客户转换';
    public static final String OA_SAMPLE_ORDER = '样品订单审批';
    public static final String OA_SALES_ORDER = '销售订单审批';
    public static final String OA_RETURN_ORDER = '退货单审批';

    // 销售组织关系记录类型
    public static final String SALES_ORG_RELATION_USER = 'UserSalesOrganization';
    public static final String SALES_ORG_RELATION_ACCOUNT = 'AccountSalesOrganization';

    // 采购组织关系记录类型
    public static final String PURCHASE_ORG_RELATION_USER = 'UserPurchaseOrganization';
    public static final String PURCHASE_ORG_RELATION_ACCOUNT = 'SupplierPurchaseOrganization';

    // 销售订单记录类型
    public static final String SALES_ORDER_INSIDE = 'ChinaOrder';
    public static final String SALES_ORDER_OUTSIDE = 'ForeignOrder';
}