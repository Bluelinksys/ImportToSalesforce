/**********************************************************************
 名    称：ImportValidateInterface
 目    的：导入验证接口
 作    者：kit.liu(liuwenjun@bluelinksys.com)
 创建日期：2018-10-08
 修 改 人：
 修改日期：
 修改原因：
 备    注：
 **********************************************************************/
public interface ImportValidateInterface {

    List<ImportBean.Info> validate(String className, Map<String, Map<Integer,Sobject>> sourceDataList);
}