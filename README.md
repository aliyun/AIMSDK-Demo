 SDK 说明：
 https://help.aliyun.com/document_detail/205671.html

 从如下地址下载 iOS 版 SDK，解压并将整个deps文件夹放置在工程目录下
  https://help.aliyun.com/document_detail/209979.html

 从如下地址下载 Android 版 SDK，解压并将相关aar拷贝到app/libs目录下
 https://help.aliyun.com/document_detail/209979.html

 目前使用的IMSDK版本为 3.0.0.23

 使用说明：
 1. StartEngine, ReleaseEngine
    启动引擎，释放引擎
 2. Reset Local DB
    清空本地缓存，将清理本地聊天数据
 3. Create Manager，Release
    创建，释放用户实例，可同时最多创建10个用户，测试账号范围(test001 - test999)
 4. Login，Loout
    用户登陆/登出
 5. List Convs
    拉取聊天首屏会话列表（包含最后一条消息）
 6. Create Conv
    创建单聊会话（群聊请自行按照Demo进行更改）
 7. Enter Conv
    进入会话，该会话的消息将自动设置为已读
 8. SendHelloWorld
    发送文本消息
 9. Send Image
    发送图片消息
 10. DownloadImage
    下载之前拉取到的图片消息的图片文件

如何替换测试环境：
```
for iOS:
// 替换下面的信息
// app key
#define DEMO_DEFAUT_APP_KEY @""
// app id
#define DEMO_DEFAULT_APP_ID @""
// AppServer地址，用于获取登陆token
#define DEMO_DEFAUT_TOKEN_URL @""

for Android:
public class Environments {
    // 替换下面的信息
    // app key
    public static String APP_KEY = "";
    // app id
    public static String APP_ID = "";
    // AppServer地址，用于获取登陆token
    public static String TOKEN_URL ="=";
}

```