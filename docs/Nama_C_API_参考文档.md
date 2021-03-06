# Nama C API 参考文档
<!--每次更新文档，更新时间-->

级别：Public   
更新日期：2020-01-19   
SDK版本: 6.6.0  

------
### 最新更新内容：

<!--这个小节写每次最新以及次新的更新记录，时间，更新内容。新增函数，函数接口定义更新-->
2020-01-19 v6.6.0:
注意: 更新SDK 6.6.0时，在fuSetup之后，需要马上调用 fuLoadAIModelFromPackage 加载ai_faceprocessor.bundle 到 FUAITYPE::FUAITYPE_FACEPROCESSOR!!!

在Nama 6.6.0及以上，AI能力的调用会按道具需求调用，避免同一帧多次调用；同时由Nama AI子系统管理推理，简化调用过程；将能力和产品功能进行拆分，避免在道具bundle内的冗余AI模型资源，方便维护升级，同时加快道具的加载；方便各新旧AI能力集成，后续的升级迭代。

基本逻辑：Nama初始化后，可以预先加载一个或多个将来可能使用到的AI能力模块。调用实时render处理接口时，Nama主pipe会在最开始的时候，分析当前全部道具需要AI能力，然后由AI子系统执行相关能力推理，然后开始调用各个道具的‘生命周期’函数，各道具只需要按需在特定的‘生命周期’函数调用JS接口获取AI推理的结果即可，并用于相关逻辑处理或渲染。

1. 新增加接口 fuLoadAIModelFromPackage 用于加载AI能力模型。
2. 新增加接口 fuReleaseAIModel 用于释放AI能力模型。
3. 新增加接口 fuIsAIModelLoaded 判断AI能力是否已经加载。
4. 新增fuSetMultiSamples接口，MSAA抗锯齿接口，解决虚拟形象等内容边缘锯齿问题。

例子1：背景分割
	a. 加载AI能力模型，fuLoadAIModelFromPackage加载ai_bgseg.bundle 到 FUAITYPE::FUAITYPE_BACKGROUNDSEGMENTATION上。
	b. 加载产品业务道具A，A道具使用了背景分割能力。
	c. 切换产品业务道具B，B道具同样使用了背景分割能力，但这时AI能力不需要重新加载。

2019-09-25 v6.4.0:

1. v6.4.0 接口无变动。

2019-08-14 v6.3.0:

1. 新增fuSetFaceTrackParam函数，用于设置人脸跟踪参数。

2019-06-27 v6.2.0:

1. fuSetFaceDetParam函数新增加参数，enable_large_pose_detection。

2019-05-27 v6.1.0:

1. 新增fuSetupLocal函数，支持离线鉴权。
2. 新增fuDestroyLibData函数，支持tracker内存释放。

2019-03-31 v6.0.0：
1. 新增fuSetFaceDetParam函数，用于设置人脸检测参数。
2. 新增fuTrackFaceWithTongue函数，支持舌头跟踪。
3. 新增fuSetTongueTracking，开/关舌头跟踪。
4. fuGetFaceInfo新增参数expression_with_tongue，获取舌头信息。
5. 废弃fuLoadExtendedARData。

------
### 目录：
<!--这个小节为目录，不用改动，为了目录好看，每个函数仅以函数名为标题无子标题，其他标题加粗显示即可-->

本文档内容目录：

[TOC]

------
### 1. 简介 
<!--简介-->

本文是相芯人脸跟踪及视频特效开发包（以下简称 Nama SDK）的底层接口文档。该文档中的 Nama API 为底层 native 接口，可以直接用于 iOS/Android NDK/Windows/Linux/Mac 上的开发。其中，iOS和Android平台上的开发可以利用SDK的应用层接口（Objective-C/Java），相比本文中的底层接口会更贴近平台相关的开发经验。

SDK相关的所有调用要求在同一个线程中顺序执行，不支持多线程。少数接口可以异步调用（如道具加载），会在备注中特别注明。SDK所有主线程调用的接口需要保持 OpenGL context 一致，否则会引发纹理数据异常。如果需要用到SDK的绘制功能，则主线程的所有调用需要预先初始化OpenGL环境，没有初始化或初始化不正确会导致崩溃。我们对OpenGL的环境要求为 GLES 2.0 以上。具体调用方式，可以参考各平台 demo。

底层接口根据作用逻辑归为六类：初始化、加载道具、主运行接口、销毁、功能接口、P2A相关接口。

------
### 2. APIs
<!--本小节描述APIs，每个函数结束候插入分割线-->
#### 2.1 初始化
##### fuSetup 函数
初始化系统环境，加载系统数据，并进行网络鉴权。必须在调用SDK其他接口前执行，否则会引发崩溃。

```C
int fuSetup(float* v3data, int sz_v3data, float* ardata, void* authdata, int sz_authdata);
```

__参数:__

*v3data [in]*： 内存指针，指向SDK提供的 v3.bundle 文件内容

*sz_v3data [in]*: v3.bundle文件字节数

*ardata [in]*： 已废弃

*authdata [in]*： 内存指针，指向鉴权数据的内容。如果是用包含 authpack.h 的方法在编译时提供鉴权数据，则这里可以写为 ```g_auth_package``` 。

*sz_authdata [in]*：鉴权数据的长度，以字节为单位。如果鉴权数据提供的是 authpack.h 中的 ```g_auth_package```，这里可写作 ```sizeof(g_auth_package)```

__返回值:__

返回非0值代表成功，返回0代表失败。如初始化失败，可以通过 ```fuGetSystemError``` 获取错误代码。

__备注:__

根据应用需求，鉴权数据也可以运行时提供（如网络下载），不过要注意证书泄露风险，防止证书被滥用。
数据长度采用了 ```int```，是为了防止跨平台的数据类型问题。  
需要在有GL Context的地方进行初始化。

------
##### fuSetupLocal 函数
初始化系统环境，加载系统数据，并进行离线鉴权。必须在调用SDK其他接口前执行，否则会引发崩溃。

```C
int fuSetupLocal(float* v3data, int sz_v3data,float* ardata,void* authdata,int sz_authdata,void** offline_bundle_ptr,int* offline_bundle_sz);

```

__参数:__

*v3data [in]*： 内存指针，指向SDK提供的 v3.bundle 文件内容

*sz_v3data [in]*: v3.bundle文件字节数

*ardata [in]*： 已废弃

*authdata [in]*： 内存指针，指向鉴权数据的内容。如果是用包含 authpack.h 的方法在编译时提供鉴权数据，则这里可以写为 ```g_auth_package``` 。

*sz_authdata [in]*：鉴权数据的长度，以字节为单位。如果鉴权数据提供的是 authpack.h 中的 ```g_auth_package```，这里可写作 ```sizeof(g_auth_package)```

*offline_bundle_ptr [in/out]*： 内存指针，指向离线证书的内容。离线证书bundle buffer的指针 。

*offline_bundle_sz [in/out]*：离线证书数据的长度，以字节为单位。

__返回值:__

返回非0值代表成功，返回0代表失败。如初始化失败，可以通过 ```fuGetSystemError``` 获取错误代码。

如果成功，参数`offline_bundle_ptr`以及`offline_bundle_sz`，会被修改为真正离线证书的内容。需要保存下来，如.bundle文件。下次初始化鉴权时使用，则不需要联网鉴权。

__备注:__  

根据应用需求，鉴权数据也可以运行时提供（如网络下载），不过要注意证书泄露风险，防止证书被滥用。

数据长度采用了 ```int```，是为了防止跨平台的数据类型问题。  

需要在有GL Context的地方进行初始化。  

第一次需要联网鉴权，鉴权成功后，保存新的证书，后面不要联网。

##### fuLoadAIModelFromPackage 函数
SDK6.6.0 新增接口，在fuSetup后，可以预先加载未来可能需要使用到的AI能力。AI模型和SDK一起发布，在Assets目录下。

```C
/**
\brief Load AI model data, to support tongue animation.
\param data - the pointer to AI model data 'ai_xxx.bundle', 
	which is along beside lib files in SDK package
\param sz - the data size, we use plain int to avoid cross-language compilation issues
\param type - define in FUAITYPE enumeration.
\return zero for failure, one for success.
*/
FUNAMA_API int fuLoadAIModelFromPackage(void* data,int sz,FUAITYPE type);
```

__参数:__

*data [in]*： 内存指针，指向SDK提供的 ai****.bundle 文件内容，为AI能力模型。

*sz [in]*: data文件字节数

*type [in]*：描述bundle对应的AI能力类型，如下：
```
typedef enum FUAITYPE{
	FUAITYPE_BACKGROUNDSEGMENTATION=1<<1,
	FUAITYPE_HAIRSEGMENTATION=1<<2,
	FUAITYPE_HANDGESTURE=1<<3,
	FUAITYPE_TONGUETRACKING=1<<4,
	FUAITYPE_FACELANDMARKS75=1<<5,
	FUAITYPE_FACELANDMARKS209=1<<6,
	FUAITYPE_FACELANDMARKS239=1<<7,
	FUAITYPE_HUMANPOSE2D=1<<8,
	FUAITYPE_BACKGROUNDSEGMENTATION_GREEN=1<<9,
	FUAITYPE_FACEPROCESSOR=1<<10
}FUAITYPE;
```

__返回值:__

返回1值代表成功，返回0代表失败。可以通过fuReleaseAIModel释放模型，以及通过fuIsAIModelLoaded查询是否AI能力模型是否已经加载。

__备注:__  

AI能力会随SDK一起发布，存放在assets/AI_Model目录中。
- ai_bgseg.bundle 为背景分割AI能力模型。
- ai_hairseg.bundle 为头发分割AI能力模型。
- ai_gesture.bundle 为手势识别AI能力模型。
- ai_facelandmarks75.bundle 为脸部特征点75点AI能力模型。
- ai_facelandmarks209.bundle 为脸部特征点209点AI能力模型。
- ai_facelandmarks239.bundle 为脸部特征点239点AI能力模型。
- ai_humanpose.bundle 为人体2D点位AI能力模型。
- ai_bgseg_green.bundle 为绿幕背景分割AI能力模型。
- ai_face_processor 为人脸面具以及人脸面罩AI能力模型，需要默认加载。

##### fuReleaseAIModel 函数
当不需要是使用特定的AI能力时，可以释放其资源，节省内存空间。1为已释放，0为未释放。

```C
/**
\brief Release AI Model, when no more need some type of AI albility.
\param type - define in FUAITYPE enumeration.
\return zero for failure, one for success.
*/
FUNAMA_API int fuReleaseAIModel(FUAITYPE type);
```

__参数:__

*type [in]*：描述bundle对应的AI能力类型，如下：
```
typedef enum FUAITYPE{
	FUAITYPE_BACKGROUNDSEGMENTATION=1<<1,
	FUAITYPE_HAIRSEGMENTATION=1<<2,
	FUAITYPE_HANDGESTURE=1<<3,
	FUAITYPE_TONGUETRACKING=1<<4,
	FUAITYPE_FACELANDMARKS75=1<<5,
	FUAITYPE_FACELANDMARKS209=1<<6,
	FUAITYPE_FACELANDMARKS239=1<<7,
	FUAITYPE_HUMANPOSE2D=1<<8,
	FUAITYPE_BACKGROUNDSEGMENTATION_GREEN=1<<9,
	FUAITYPE_FACEPROCESSOR=1<<10
}FUAITYPE;
```

__返回值:__

1为已释放，0为未释放。

__备注:__  

AI能力模型内存占用不高，建议长驻内存。  

------
##### fuIsAIModelLoaded 函数
获取AI能力是否已经加载的状态，0为未加载，1为加载。

```C
/**
\brief Get AI Model load status
\param type - define in FUAITYPE enumeration.
\return zero for unloaded, one for loaded.
*/
FUNAMA_API int fuIsAIModelLoaded(FUAITYPE type);
```

__参数:__

*type [in]*：描述bundle对应的AI能力类型，如下：
```
typedef enum FUAITYPE{
	FUAITYPE_BACKGROUNDSEGMENTATION=1<<1,
	FUAITYPE_HAIRSEGMENTATION=1<<2,
	FUAITYPE_HANDGESTURE=1<<3,
	FUAITYPE_TONGUETRACKING=1<<4,
	FUAITYPE_FACELANDMARKS75=1<<5,
	FUAITYPE_FACELANDMARKS209=1<<6,
	FUAITYPE_FACELANDMARKS239=1<<7,
	FUAITYPE_HUMANPOSE2D=1<<8,
	FUAITYPE_BACKGROUNDSEGMENTATION_GREEN=1<<9,
	FUAITYPE_FACEPROCESSOR=1<<10
}FUAITYPE;
```

__返回值:__

0为未加载，1为加载。

__备注:__  

AI能力模型内存占用不高，建议长驻内存。

------

#### 2.2 加载道具包

##### fuCreateItemFromPackage 函数

加载道具包，使其可以在主运行接口中被执行。一个道具包可能是一个功能模块或者多个功能模块的集合，加载道具包可以在流水线中激活对应的功能模块，在同一套SDK调用逻辑中实现即插即用。

``` C
int fuCreateItemFromPackage(void* data, int sz);
```

__参数:__  

*data [in]*： 内存指针，指向所加载道具包的内容。道具包通常以 \*.bundle 结尾。

*sz [in]*：道具包内容的数据长度，以字节为单位。

__返回值:__

一个整数句柄，作为该道具在系统内的标识符。

__备注:__  

该接口可以和主线程异步执行。为了降低加载道具阻塞主线程，建议异步调用该接口。

------
##### fuItemSetParam 函数

修改或设定道具包中变量的值。可以支持的道具包变量名、含义、及取值范围需要参考道具的文档。

```C
// 设定道具中的double类型变量
int fuItemSetParamd(int item,char* name,double value);
// 设定道具中的double数组类型变量
int fuItemSetParamdv(int item,char* name,double* value,int n);
// 设定道具中的字符串类型变量
int fuItemSetParams(int item,char* name,char* value);
```

__参数:__

*item [in]*： 道具表示符，内容应为调用 ```fuCreateItemFromPackage``` 函数的返回值，并且道具内容没有被销毁。

*name [in]*：字符串指针，内容为要设定的道具变量名。

*value [in]*：要设定的变量值，数据类型对应不同的函数接口。

*n [in]*：设定变量为double数组时，数组数据的长度，以double为单位。

__返回值:__

返回非0值代表成功，返回0代表失败。

__备注:__

设定变量为字符串时，要求字符串以0结尾。

------
##### fuItemGetParam 函数
获取道具中变量的值。可以支持的道具包变量名、含义、及取值范围需要参考道具的文档。

```C
// 获取道具中的浮点类型变量
double fuItemGetParamd(int item,char* name);
```
__参数:__

*item [in]*： 道具表示符，内容应为调用 fuCreateItemFromPackage 函数的返回值，并且道具内容没有被销毁。

*name [in]*：字符串指针，内容为要获取的道具变量名。

__返回值:__

要获取的变量的值。执行失败的情况下返回值为0。  

__备注:__  

该接口可以和主线程异步执行。

------
##### fuItemGetParams 函数
获取道具中的字符串类型变量。

```C
// 获取道具中的字符串类型变量
int fuItemGetParams(int item,char* name,char* buf,int sz);
```

__参数:__  

*item [in]*： 道具表示符，内容应为调用 ```fuCreateItemFromPackage``` 函数的返回值，并且道具内容没有被销毁。

*name [in]*：字符串指针，内容为要修改的道具变量名。

*buf [out]*：内存指针，指向预分配的内存空间，用于接收函数返回的字符串内容。

*sz [in]*：在*buf*中预分配的最大内存长度，以字节为单位。

__返回值:__  

返回为变量字符串的长度。执行失败的情况下返回值为-1。  

__备注:__  

该接口可以和主线程异步执行。  


#### 2.3 主运行接口
------
##### fuRenderItems 函数
将输入的图像数据，送入SDK流水线进行处理，并输出处理之后的图像数据。该接口会执行所有道具要求、且证书许可的功能模块，包括人脸检测与跟踪、美颜、贴纸或avatar绘制等。

该接口支持两种输入输出模式，输入RGBA纹理并输出RGBA纹理，或者输入BGRA数组输出BGRA数组。其中RGBA纹理为OpenGL纹理，该模式下传入输入纹理的ID，并在函数返回值中返回输出的纹理ID。BGRA数组为内存图像缓存，数据格式为8位4通道的图像，该模式下将输入图像通过参数传入，输出图像会覆盖到同一内存空间中。

```C
int fuRenderItems(int texid,int* img,int w,int h,int frame_id, int* p_items,int n_items);
```

__参数:__  

*texid [in]*：纹理模式下输入的OpenGL纹理ID，非纹理模式下传0。

*img [in & out]*：内存数组模式下输入的图像数据，处理后的图像数据也覆盖在该内存空间中。纹理模式下该参数可以传NULL。

*w [in]*：输入的图像宽度。

*h [in]*：输入的图像高度。

*frame_id [in]*：当前处理的帧序列号，用于控制道具中的动画逻辑。

*p_items [in]*：内存指针，指向需要执行的道具标识符数组。其中每个标识符应为调用 ```fuCreateItemFromPackage``` 函数的返回值，并且道具内容没有被销毁。

*n_items [in]*：*p_items*数组中的道具个数。


__返回值:__  

处理之后的输出图像的纹理ID。返回值小于等于0为异常，具体信息通过`fuGetSystemError`获取。

__备注:__  

即使在非纹理模式下，函数仍会返回输出图像的纹理ID。虽然该模式下输入输出都是内存数组，但是绘制工作仍然是通过GPU完成的，因此该输出图像的纹理ID同样存在。输出的OpenGL纹理为SDK运行时在当前OpenGL context中创建的纹理，其ID应与输入ID不同。输出后使用该纹理时需要确保OpenGL context保持一致。

该绘制接口需要OpenGL环境，环境异常会导致崩溃。

------
##### fuRenderItemsEx 函数
将输入的图像数据，送入SDK流水线进行处理，并输出处理之后的图像数据。该接口会执行所有道具要求、且证书许可的功能模块，包括人脸检测与跟踪、美颜、贴纸或avatar绘制等。

相比 ```fuRenderItems``` 该接口支持更加灵活多样的输入及输出模式，详细的输入输出格式列表参加后续章节 [输入输出格式列表](#输入输出格式列表) 。

```C
int fuRenderItemsEx(
	int out_format,void* out_ptr,
	int in_format,void* in_ptr,
	int w,int h,int frame_id, int* p_items,int n_items);
```

__参数:__  

*out_format [in]*：输出的数据格式标识符。

*out_ptr [out]*：内存指针，指向输出的数据内容。

*in_format [in]*：输入的数据格式标识符。

*in_ptr [in]*：内存指针，指向输入的数据内容。

*w [in]*：输入的图像宽度。

*h [in]*：输入的图像高度。

*frame_id [in]*：当前处理的帧序列号，用于控制道具中的动画逻辑。

*p_items [in]*：内存指针，指向需要执行的道具标识符数组。其中每个标识符应为调用 ```fuCreateItemFromPackage``` 函数的返回值，并且道具内容没有被销毁。

*n_items [in]*：*p_items*数组中的道具个数。

__返回值:__  

处理之后的输出图像的纹理ID。

__备注:__  

即使在非纹理模式下，函数仍会返回输出图像的纹理ID。虽然输出的图像可能是多种可选格式，但是绘制工作总是通过GPU完成，因此输出图像的纹理ID始终存在。输出的OpenGL纹理为SDK运行时在当前OpenGL context中创建的纹理，其ID应与输入ID不同。输出后使用该纹理时需要确保OpenGL context保持一致。  

该绘制接口需要OpenGL环境，环境异常会导致崩溃。

------
##### fuRenderItemsEx2 函数
将输入的图像数据，送入SDK流水线进行处理，并输出处理之后的图像数据。

相比 ```fuRenderItemsEx``` 该接口增加了用户对流水线的控制。通过传入流水线功能掩码参数，可以控制指定功能模块的开关，以及特定的绘制选项。通过传入道具掩码数组，可以控制每个道具在多人脸情况下对哪些人脸生效。

```C
int fuRenderItemsEx2(
	int out_format,void* out_ptr,
	int in_format,void* in_ptr,
	int w,int h,int frame_id, int* p_items,int n_items,
	int func_flag, int* p_item_masks);
```

__参数:__  

*out_format [in]*：输出的数据格式标识符。

*out_ptr [out]*：内存指针，指向输出的数据内容。

*in_format [in]*：输入的数据格式标识符。

*in_ptr [in]*：内存指针，指向输入的数据内容。

*w [in]*：输入的图像宽度。

*h [in]*：输入的图像高度。

*frame_id [in]*：当前处理的帧序列号，用于控制道具中的动画逻辑。

*p_items [in]*：内存指针，指向需要执行的道具标识符数组。其中每个标识符应为调用 ```fuCreateItemFromPackage``` 函数的返回值，并且道具内容没有被销毁。

*n_items [in]*：*p_items*数组中的道具个数。

*func_flag*：流水线功能掩码，表示流水线启用的功能模组，以及特定的绘制选项。多个掩码通过运算符“或”进行连接。所有支持的掩码及其含义如下。

| 流水线功能掩码     | 含义     |
| ---- | ---- |
| NAMA_RENDER_FEATURE_TRACK_FACE     | 人脸识别和跟踪功能     |
| NAMA_RENDER_FEATURE_BEAUTIFY_IMAGE     | 输入图像美化功能     |
| NAMA_RENDER_FEATURE_RENDER     | 人脸相关的绘制功能，如美颜、贴纸、人脸变形、滤镜等     |
| NAMA_RENDER_FEATURE_ADDITIONAL_DETECTOR     | 其他非人脸的识别功能，包括背景分割、手势识别等     |
| NAMA_RENDER_FEATURE_RENDER_ITEM     | 人脸相关的道具绘制，如贴纸     |
| NAMA_RENDER_FEATURE_FULL     | 流水线功能全开     |
| NAMA_RENDER_OPTION_FLIP_X     | 绘制选项，水平翻转     |
| NAMA_RENDER_OPTION_FLIP_Y     | 绘制选项，垂直翻转     |

*p_item_masks*：道具掩码，表示在多人模式下，每个道具具体对哪几个人脸生效。该数组长度应和 *p_items* 一致，每个道具一个int类型掩码。掩码中，从int低位到高位，第i位值为1代表该道具对第i个人脸生效，值为0代表不生效。

__返回值:__  

处理之后的输出图像的纹理ID。

__备注:__  

即使在非纹理模式下，函数仍会返回输出图像的纹理ID。虽然输出的图像可能是多种可选格式，但是绘制工作总是通过GPU完成，因此输出图像的纹理ID始终存在。输出的OpenGL纹理为SDK运行时在当前OpenGL context中创建的纹理，其ID应与输入ID不同。输出后使用该纹理时需要确保OpenGL context保持一致。

该绘制接口需要OpenGL环境，环境异常会导致崩溃。

------
##### fuBeautifyImage 函数
将输入的图像数据，送入SDK流水线进行全图美化，并输出处理之后的图像数据。该接口仅执行图像层面的美化处理（包括滤镜、美肤），不执行人脸跟踪及所有人脸相关的操作（如美型）。由于功能集中，相比```fuRenderItemsEx``` 接口执行美颜道具，该接口所需计算更少，执行效率更高。

```C
int fuBeautifyImage(
	int out_format,void* out_ptr,
	int in_format,void* in_ptr,
	int w,int h,int frame_id, int* p_items,int n_items);
```

__参数:__  

*out_format [in]*：输出的图像数据格式。

*out_ptr [out]*：内存指针，指向输出的图像数据。

*in_format [in]*：输入的图像数据格式。

*in_ptr [in]*：内存指针，指向输入的图像数据。

*w [in]*：输入的图像宽度。

*h [in]*：输入的图像高度。

*frame_id [in]*：当前处理的帧序列号，用于控制道具中的动画逻辑。

*p_items [in]*：内存指针，指向需要执行的道具标识符数组。其中每个标识符应为调用 ```fuCreateItemFromPackage``` 函数的返回值，并且道具内容没有被销毁。

*n_items [in]*：*p_items*数组中的道具个数。

__返回值:__  

处理之后的输出图像的纹理ID。

__备注:__  

该接口正常生效需要传入的道具中必须包含美颜道具（随SDK分发，文件名通常为```face_beautification.bundle```）。传入道具中所有非美颜道具不会生效，也不会占用计算资源。

该绘制接口需要OpenGL环境，环境异常会导致崩溃。

------
##### fuTrackFace 函数
对于输入的图像数据仅执行人脸跟踪操作，其他所有图像和绘制相关操作均不执行，因此该函数没有图像输出。由于该函数不执行绘制相关操作，仅包含CPU计算，可以在没有OpenGL环境的情况下正常运行。该函数执行人脸跟踪操作后，结果产生的人脸信息通过 ```fuGetFaceInfo``` 接口进行获取（TODO：加链接）。

```C
int fuTrackFace(int in_format,void* in_ptr,int w,int h);
```

__参数:__  

*in_format [in]*：输入的图像数据格式。

*in_ptr [in]*：内存指针，指向输入的图像数据。

*w [in]*：输入的图像宽度。

*h [in]*：输入的图像高度。

__返回值:__  

在图像中成功跟踪到的人脸数量。

__备注:__  

该函数仅支持部分输入图像格式，包括 RGBA_BUFFER，BGRA_BUFFER，NV12 BUFFER，NV21 BUFFER。

该接口不需要绘制环境，但仍需要在SDK主线程中运行。

------
##### fuTrackFaceWithTongue 函数
同``` fuTrackFace``` ，在跟踪人脸表情的同时，跟踪舌头blendshape系数。  
对于输入的图像数据仅执行人脸跟踪操作，其他所有图像和绘制相关操作均不执行，因此该函数没有图像输出。由于该函数不执行绘制相关操作，仅包含CPU计算，可以在没有OpenGL环境的情况下正常运行。该函数执行人脸跟踪操作后，结果产生的人脸信息通过 ```fuGetFaceInfo``` 接口进行获取。

```C
int fuTrackFaceWithTongue(int in_format,void* in_ptr,int w,int h);
```

__参数:__  

*in_format [in]*：输入的图像数据格式。

*in_ptr [in]*：内存指针，指向输入的图像数据。

*w [in]*：输入的图像宽度。

*h [in]*：输入的图像高度。

__返回值:__  

在图像中成功跟踪到的人脸数量。

__备注:__  

需要加载 tongue.bundle,才能开启舌头跟踪。

可通过 ```fuGetFaceInfo(0,"expression_with_tongue",pret,56)```获取包含舌头的表情系数。 



------

#### 2.4 销毁

当不需要使用SDK时，可以释放SDK相关内存，包括道具渲染使用内存，以及人脸跟踪模块的内存。 

##### fuDestroyItem 函数
销毁一个指定道具。

```C
void fuDestroyItem(int item);
```

__参数:__  

*item [in]*：道具标识符，该标识符应为调用 ```fuCreateItemFromPackage``` 函数的返回值，并且道具没有被销毁。

__备注:__  

该函数调用后，会即刻释放道具标识符，道具占用的内存无法瞬时释放，需要等 SDK 后续执行主处理接口时通过 GC 机制回收。

------
##### fuDestroyAllItems 函数
销毁系统加载的所有道具，并且会释放系统运行时占用的所有资源。

```C
void fuDestroyAllItems();
```

__备注:__  

该函数会即刻释放系统所占用的资源。但不会破坏 ```fuSetup``` 的系统初始化信息，应用临时挂起到后台时可以调用该函数释放资源，再次激活时无需重新初始化系统。

------
##### fuOnDeviceLost 函数
特殊函数，当 OpenGL context 被外部释放/破坏时调用，用于重置系统的 GL 状态。

```C
void fuOnDeviceLost();
```

__备注:__  

该函数仅在无法在原 OpenGL context 内正确清理资源的情况下调用。调用该函数时，会尝试进行资源清理和回收，所有系统占用的内存资源会被释放，但由于 context 发生变化，OpenGL 资源相关的内存可能会发生泄露。

------
##### fuDestroyLibData 函数
特殊函数，当不再需要Nama SDK时，可以释放由 ```fuSetup```初始化所分配的人脸跟踪模块的内存，约30M左右。调用后，人脸跟踪以及道具绘制功能将失效， ```fuRenderItemEx ```，```fuTrackFace```等函数将失败。如需使用，需要重新调用 ```fuSetup```进行初始化。

```C
void fuDestroyLibData();
```

------

#### 2.5 功能接口 - 系统

##### fuOnCameraChange 函数
在相机数据来源发生切换时调用（例如手机前/后置摄像头切换），用于重置人脸跟踪状态。  
```C
void fuOnCameraChange();
```

__备注:__  

在其他人脸信息发生残留的情景下，也可以调用该函数来清除人脸信息残留。或相机切换时，触发重置人脸跟踪模块。

------
##### fuSetFaceDetParam 函数
设置人脸检测器相关参数，__建议使用默认参数__。

```C
int fuSetFaceDetParam(char* name, float* pvalue);
```
__参数:__  

*name*：参数名。

*pvalue*: 参数值。

- 设置 `name == "use_new_cnn_detection"` ，且 `pvalue == 1` 则使用默认的CNN-Based人脸检测算法，否则 `pvalue == 0`则使用传统人脸检测算法。默认开启该模式。
- 设置 `name == "other_face_detection_frame_step"` ，如果当前状态已经检测到一张人脸后，可以通过设置该参数，每隔`step`帧再进行其他人脸检测，有助于提高性能，设置过大会导致延迟感明显，默认值10。

如果`name == "use_new_cnn_detection"` ，且 `pvalue == 1` 已经开启：
- `name == "use_cross_frame_speedup"`，`pvalue==1`表示，开启交叉帧执行推理，每帧执行半个网络，下帧执行下半个网格，可提高性能。默认 `pvalue==0`关闭。
- - `name == "enable_large_pose_detection"`，`pvalue==1`表示，开启正脸大角度(45度)检测优化。`pvalue==0`表示关闭。默认 `pvalue==1`开启。
- `name == "small_face_frame_step"`，`pvalue`表示每隔多少帧加强小脸检测。极小脸检测非常耗费性能，不适合每帧都做。默认`pvalue==5`。
- 检测小脸时，小脸也可以定义为范围。范围下限`name == "min_facesize_small"`，默认`pvalue==18`，表示最小脸为屏幕宽度的18%。范围上限`name == "min_facesize_big"`，默认`pvalue==27`，表示最小脸为屏幕宽度的27%。该参数必须在`fuSetup`前设置。

否则，当`name == "use_new_cnn_detection"` ，且 `pvalue == 0`时：
- `name == "scaling_factor"`，设置图像金字塔的缩放比，默认为1.2f。
- `name == "step_size"`，滑动窗口的滑动间隔，默认 2.f。
- `name == "size_min"`，最小人脸大小，多少像素。 默认 50.f 像素，参考640x480分辨率。
- `name == "size_max"`，最大人脸大小，多少像素。 默认最大，参考640x480分辨率。
- `name == "min_neighbors"`，内部参数, 默认 3.f
- `name == "min_required_variance"`， 内部参数, 默认 15.f

__返回值:__  

设置后状态，1 设置成功，0 设置失败。 

__备注:__  

`name == "min_facesize_small"`，`name == "min_facesize_small"`参数必须在`fuSetup`前设置。

------
##### fuSetFaceTrackParam 函数
设置人脸表情跟踪相关参数，__建议使用默认参数__。

```C
int fuSetFaceTrackParam(char* name, float* pvalue);
```
__参数:__  

*name*：参数名。

*pvalue*: 参数值。

- 设置 `name == "mouth_expression_more_flexible"` ，`pvalue = [0,1]`，默认 `pvalue = 0` ，从0到1，数值越大，嘴部表情越灵活。  

__返回值:__  

设置后状态，1 设置成功，0 设置失败。 

__备注:__  

------
##### fuSetTongueTracking 函数
开启舌头的跟踪。
```C
/**
\brief Turn on or turn off Tongue Tracking, used in trackface.
\param enable > 0 means turning on, enable <= 0 means turning off
*/
FUNAMA_API int fuSetTongueTracking(int enable);
```

__备注:__  

当使用fuTrackFaceWithTongue接口时，加载了tongue.bundle后，需要fuSetTongueTracking(1)开启舌头跟踪的支持。 
如果道具本身带舌头bs，则不需要主动开启。

------
#####  fuSetASYNCTrackFace 函数
设置人脸跟踪异步接口。默认处于关闭状态。
```C
int fuSetASYNCTrackFace(int enable);
```
__参数:__  

*enable[int]*：1 开启异步跟踪，0 关闭异步跟踪。

__返回值: __ 

设置后跟踪状态，1 异步跟踪已经开启，0 异步跟踪已经关闭。 

__备注:__  

默认处于关闭状态。开启后，人脸跟踪会和渲染绘制异步并行，cpu占用略有上升，但整体速度提升，帧率提升。

------
#####  fuSetMultiSamples 函数
设置MSAA抗锯齿功能的采样数。默认为0，处于关闭状态。
```C
int fuSetMultiSamples(int samples);
```
__参数:__  

*samples[int]*：默认为0，处于关闭状态。samples要小于等于设备GL_MAX_SAMPLES，通常可以设置4。

__返回值: __ 

设置后系统的采样数，设置成功返回samples。 

__备注:__  

该功能为硬件抗锯齿功能，需要ES3的Context。

------
#####  fuIsTracking 函数
获取当前人脸跟踪状态，返回正在跟踪的人脸数量。
```C
int fuIsTracking();
```

__返回值:__  

正在跟踪的人脸数量。

__备注:__  

正在跟踪的人脸数量会受到 `fuSetMaxFaces` 函数的影响，不会超过该函数设定的最大值。

------
##### fuSetDefaultOrientation 函数
设置默认的人脸朝向。正确设置默认的人脸朝向可以显著提升人脸首次识别的速度。  
```C
void fuSetDefaultOrientation(int rmode);  
```
__参数:__  

*rmode [in]*：要设置的人脸朝向，取值范围为 0-3，分别对应人脸相对于图像数据旋转0度、90度、180度、270度。 

__备注:__  

一般来说，iOS的原生相机数据是竖屏的，不需要进行该设置。Android 平台的原生相机数据为横屏，需要进行该设置加速首次识别。根据经验，Android 前置摄像头一般设置参数 1，后置摄像头一般设置参数 3。部分手机存在例外，自动计算的代码可以参考 fuLiveDemo。

------
##### fuSetMaxFaces 函数
设置系统跟踪的最大人脸数。默认值为1，该值增大会降低人脸跟踪模块的性能，推荐在所有可以设计为单人脸的情况下设置为1。
```C
int fuSetMaxFaces(int n);
```
__参数:__  

*n [in]*：要设置的最大人脸数。

__返回值:__  

设置之前的系统最大人脸数。

------
##### fuGetFaceInfo 函数
在主接口执行过人脸跟踪操作后，通过该接口获取人脸跟踪的结果信息。获取信息需要证书提供相关权限，目前人脸信息权限包括以下级别：默认、Landmark、Avatar。
```C
int fuGetFaceInfo(int face_id, char* name, float* pret, int num);
```
__参数:__  

*face_id [in]*：人脸编号，表示识别到的第 x 张人脸，从0开始。

*name [in]*：要获取信息的名称。

*pret [out]*：返回数据容器，需要在函数调用前分配好内存空间。

*num [in]*：返回数据容器的长度，以 sizeof(float) 为单位。

__返回值:__  

返回 1 代表获取成功，信息通过 pret 返回。返回 0 代表获取失败，具体失败信息会打印在平台控制台。如果返回值为 0 且无控制台打印，说明所要求的人脸信息当前不可用。

__备注:__  

所有支持获取的信息、含义、权限要求如下：

| 信息名称       | 长度 | 类型|含义                                                         | 权限     |
| -------------- | ---- | ------------------------------------------------------------ | -------- | -------- |
| face_rect      | 4    | float |人脸矩形框，图像分辨率坐标，数据为 (x_min, y_min, x_max, y_max) | 默认     |
| rotation_mode  | 1    | int |识别人脸相对于设备图像的旋转朝向，取值范围 0-3，分别代表旋转0度、90度、180度、270度 | 默认     |
| failure_rate   | 1    | float |人脸跟踪的失败率，表示人脸跟踪的质量。取值范围为 0-2，取值越低代表人脸跟踪的质量越高 | 默认     |
| is_calibrating | 1    | int |表示是否SDK正在进行主动表情校准，取值为 0 或 1。             | 默认     |
| focal_length   | 1    | float| SDK当前三维人脸跟踪所采用的焦距数值                          | 默认     |
| landmarks      | 75x2 | float|人脸 75 个特征点，图像分辨率坐标                             | Landmark |
| rotation       | 4    | float|人脸三维旋转，数据为旋转四元数\*                              | Landmark |
| translation    | 3    | float|人脸三维平移，数据为 (x, y, z)                               | Landmark |
| eye_rotation   | 4    | float| 眼球旋转，数据为旋转四元数\*，上下22度，左右30度。                                  | Landmark |
| eye_rotation_xy   | 2    | float| 眼球旋转，数据范围为[-1,1]，第一个通道表示水平方向转动，第二个通道表示垂直方向转动                                  | Landmark |
| expression     | 46   | float| 人脸表情系数，表情系数含义可以参考《Expression Guide》       | Avatar   |
| expression_with_tongue     | 56   | float | 1-46为人脸表情系数，同上expression，表情系数含义可以参考《Expression Guide》。47-56为舌头blendshape系数       | Avatar   |
| armesh_vertex_num     | 1   |int| armesh三维网格顶点数量       | armesh   |
| armesh_face_num     | 1   | int| armesh三维网格三角面片数量       | armesh   |
| armesh_vertices     | armesh_vertex_num * 3   |float| armesh三维网格顶点位置数据       | armesh   |
| armesh_uvs     | armesh_vertex_num * 2   |float| armesh三维网格顶点纹理数据       | armesh   |
| armesh_faces     | armesh_face_num * 3   |int| armesh三维网格三角片数据       | armesh  |
| armesh_trans_mat     | 4x4 |float| armesh 的transformation。 __注意:__ 1. 获取'armesh_trans_mat'前需要先获取对应脸的'armesh_vertices'。2. 该trans_mat,相比使用'position'和'rotation'重算的transform更加准确，配合armesh，更好贴合人脸。 | armesh  |
*注：旋转四元数转换为欧拉角可以参考 [该网页](https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles)。

获取三维网格代码参考
```C
	int vercnt = 0;
	fuGetFaceInfo(0, "armesh_vertex_num", (float*)&vercnt, 1);
	logi("armesh_vertex_num %d: %f", (int)vercnt,vercnt);
	int facecnt = 0;
	fuGetFaceInfo(0, "armesh_face_num", (float*)&facecnt, 1);
	logi("armesh_face_num %d:", facecnt);
	vector<float> v, vt;
	vector<int>f;
	vector<float> trans;
	v.resize(vercnt * 3);
	vt.resize(vercnt * 2);
	f.resize(facecnt* 3);
	trans.resize(16);
	int ret1 = fuGetFaceInfo(0, "armesh_vertices", v.data(), v.size());
	int ret2 = fuGetFaceInfo(0, "armesh_uvs", vt.data(), vt.size());
	int ret3 = fuGetFaceInfo(0, "armesh_faces", (float*)f.data(), f.size());
	int ret4 = fuGetFaceInfo(0, "armesh_trans_mat", (float*)trans.data(), trans.size());//after 'armesh_vertices'
	logi("ret1: %d ret2: %d ret3: %d ret4: %d\n", ret1, ret2, ret3, ret4);
	logi("armesh_trans_mat:[");
	for (auto i = 0; i < 15; i++) {
		logi("%f,", trans[i]);
	}
	logi("%f]\n", trans[15]);
	string str = "";
	ostringstream osstr(str);
	for (int i = 0; i < vercnt; i++) {
		osstr << "v " << std::to_string(v[i * 3 + 0]) << " " << std::to_string(v[i * 3 + 1]) << " " << std::to_string(v[i * 3 + 2]) << "\n";
	}
	for (int i = 0; i < vercnt; i++) {
		osstr << "vt " << std::to_string(vt[i * 2 + 0]) << " " << std::to_string(vt[i * 2 + 1]) << "\n";
	}
	for (int i = 0; i < facecnt; i++) {
		osstr << "f " << std::to_string(f[i * 3 + 0]+1) << " " << std::to_string(f[i * 3 + 1]+1) << " " << std::to_string(f[i * 3 + 2]+1) << "\n";
	}
	string objfile = "./face.obj";
	ofstream ost;
	ost.open(objfile);
	str = osstr.str();
	ost.write(str.c_str(),str.length());
```

获取头的旋转四元数，并转换为欧拉角的示例代码
```C
float rotation[4];
int ret = fuGetFaceInfo(0, "rotation", rotation, 4);
if (ret){
	Quaternion<float> q;
	q.v[0] = rotation[0];
	q.v[1] = rotation[1];
	q.v[2] = rotation[2];
	q.w = rotation[3];
	Float3 vec = q.toAngles();
	vec *= 180 / 3.14;
	logi("rotation angle:[%f,%f,%f]\n", vec.x(), vec.y(), vec.z());
}
```
获取头的二维特征点，并绘制到二维屏幕空间的示例代码
```C
float data[150];
//logi("render\n");
int ret = fuGetFaceInfo(0, "landmarks", data, 150);
if (ret){
	for (int i = 0; i < 75; i++){
		//logi("%d :[%d,%d]\n", i, (int)data[i * 2], (int)data[i * 2 + 1]);
		cv::Point pointInterest;
		pointInterest.x = data[i * 2];
		pointInterest.y = data[i * 2 + 1];
		cvCircle(frameNamaProtrait, pointInterest, 2, cv::Scalar(0, 0, 255));
	}
}
```
获取头的三维特征点，并投影到二维屏幕空间的示例代码
```C
float dde_rotation[4];
float dde_translation[3];
float dde_projection_matrix[16];
float dde_landmark_ar[75 * 3];
int ret = fuGetFaceInfo(0, "rotation", dde_rotation, 4);
ret = fuGetFaceInfo(0, "translation", dde_translation, 3);
ret = fuGetFaceInfo(0, "projection_matrix", dde_projection_matrix, 16);
ret = fuGetFaceInfo(0, "landmarks_ar", dde_landmark_ar, 75 * 3);
QuaternionF qrot; qrot.v[0] = dde_rotation[0]; qrot.v[1] = dde_rotation[1]; qrot.v[2] = dde_rotation[2]; qrot.w = dde_rotation[3];
Float3 tran(dde_translation[0], dde_translation[1], dde_translation[2]);
Mat4f trans_mat = qrot.toRotationMatrix();
for (int i = 0; i < 3; i++){
	trans_mat(i, 3) = tran[i];
}
Mat4f project_mat(dde_projection_matrix);
//logi("trans:[%f,%f,%f]\n", dde_translation[0], dde_translation[1], dde_translation[2]);
int screen_w = frameNamaProtrait->width;
int screen_h = frameNamaProtrait->height;
for (int i = 0; i < 75; i++){
	Float4 pos = Float4(dde_landmark_ar[i * 3], dde_landmark_ar[i * 3 + 1], dde_landmark_ar[i * 3 + 2],1);
	//to screen space
	pos = project_mat.trans() * trans_mat * pos;
	pos /= pos[3];
	Float3 store;
	store[0] = (pos[0] + 1) * screen_w - screen_w/2;
	store[1] = (pos[1] + 1) * screen_h - screen_h / 2;
	store[0] = (int)floor(store[0]);
	store[1] = (int)floor(store[1]);
	//draw
	cv::Point pointInterest;
	pointInterest.x = store[0];
	pointInterest.y = store[1];
	cvCircle(frameNamaProtrait, pointInterest, 2, cv::Scalar(0,0,255 ));
}
```

------
##### fuGetFaceIdentifier 函数
获取正在跟踪人脸的标识符，用于在SDK外部对多人情况下的不同人脸进行区别。
```C
int fuGetFaceIdentifier(int face_id);
```
__参数:__  

*face_id [in]*：人脸编号，表示识别到的第 x 张人脸，从0开始。

__返回值:__  

所要求的人脸标识符。

__备注:__  

跟踪失败会改变标识符，包括快速的重跟踪。

------
##### fuGetVersion 函数
返回SDK版本。
```C
const char* fuGetVersion();
```

__返回值:__  

一个常量字符串指针，版本号表示如下：
“主版本号\_子版本号\-版本校检值”

------
##### fuGetSystemError 函数
返回系统错误，该类错误一般为系统机制出现严重问题，导致系统关闭，因此需要重视。
```C
const int fuGetSystemError();
```

__返回值:__  

系统错误代码。

__备注:__  

复数错误存在的情况下，会以位运算形式编码在一个代码中。如果返回代码不对应以下列表中任何一个单一代码，则说明存在复数错误，此时可以通过 `fuGetSystemErrorString` 函数解析最重要的错误信息。

系统错误代码及其含义如下：

| 错误代码 | 错误信息                          |
| -------- | --------------------------------- |
| 1        | 随机种子生成失败                  |
| 2        | 机构证书解析失败                  |
| 3        | 鉴权服务器连接失败                |
| 4        | 加密连接配置失败                  |
| 5        | 客户证书解析失败                  |
| 6        | 客户密钥解析失败                  |
| 7        | 建立加密连接失败                  |
| 8        | 设置鉴权服务器地址失败            |
| 9        | 加密连接握手失败                  |
| 10       | 加密连接验证失败                  |
| 11       | 请求发送失败                      |
| 12       | 响应接收失败                      |
| 13       | 异常鉴权响应                      |
| 14       | 证书权限信息不完整                |
| 15       | 鉴权功能未初始化                  |
| 16       | 创建鉴权线程失败                  |
| 17       | 鉴权数据被拒绝                    |
| 18       | 无鉴权数据                        |
| 19       | 异常鉴权数据                      |
| 20       | 证书过期                          |
| 21       | 无效证书                          |
| 22       | 系统数据解析失败                  |
| 0x100    | 加载了非正式道具包（debug版道具） |
| 0x200    | 运行平台被证书禁止                |

------
##### fuGetSystemErrorString 函数
解析系统错误代码，并返回可读信息。
```C
const char* fuGetSystemErrorString(int code);
```
__参数:__  

*code [in]*：系统错误代码，一般为 ```fuGetSystemError``` 所返回的代码。

__返回值:__  

一个常量字符串，解释了当前错误的含义。

__备注:__  

当多个错误存在的情况下，该函数会返回当前最为重要的错误信息。

------
##### fuCheckDebugItem 函数
检查一个道具包是否为非正式道具包（debug版道具）。
```C
const int fuCheckDebugItem(void* data,int sz);
```
__参数:__  

*data [in]*：内存指针，指向所加载道具包的内容。道具包通常以 \*.bundle 结尾。

*sz [in]*：道具包内容的数据长度，以字节为单位。

__返回值:__  

返回值 0 代表该道具为正式道具，返回值 1 代表该道具为非正式道具（debug版道具），返回值 -1 代表该道具数据异常。

__备注:__  

如果系统加载过非正式版道具，会导致系统进入倒计时，并在倒计时结束时关闭。如果系统提示 “debug item used”，或系统在运行1分钟后停止，则需要利用该函数检查所有加载过的道具，如果有非正式道具需要进行正确的道具签名。

道具签名流程请联系技术支持。

------
#### 2.6 功能接口-效果
##### fuSetExpressionCalibration 函数
设置人脸表情校准功能。该功能的目的是使表情识别模块可以更加适应不同人的人脸特征，以实现更加准确可控的表情跟踪效果。

该功能分为两种模式，主动校准 和 被动校准。
- 主动校准：该种模式下系统会进行快速集中的表情校准，一般为初次识别到人脸之后的2-3秒钟。在该段时间内，需要用户尽量保持无表情状态，该过程结束后再开始使用。该过程的开始和结束可以通过 ```fuGetFaceInfo``` 接口获取参数 ```is_calibrating```。
- 被动校准：该种模式下会在整个用户使用过程中逐渐进行表情校准，用户对该过程没有明显感觉。该种校准的强度比主动校准较弱。

默认状态为开启被动校准。
```C
void fuSetExpressionCalibration(int mode);
```
__参数:__  

*mode [in]*：表情校准模式，0为关闭表情校准，1为主动校准，2为被动校准。

__备注:__  

当利用主处理接口处理静态图片时，由于需要针对同一数据重复调用，需要将表情校准功能关闭。

------
##### fuSetStrictTracking 函数
启用更加严格的跟踪质量检测。

该功能启用后，当面部重要五官出现被遮挡、出框等情况，以及跟踪质量较差时，会判断为跟踪失败，避免系统在跟踪质量较低时出现异常跟踪数据。
```C
void fuSetStrictTracking(int mode);
```
__参数:__  

*mode [in]*：0为禁用，1为启用，默认为禁用状态。

------
##### fuSetFocalLengthScale 函数
修改系统焦距（效果等价于focal length, 或FOV），影响三维跟踪、AR效果的透视效果。
参数为一个比例系数，焦距变大会带来更小的透视畸变。
```C
/**
\brief Scale the rendering perspectivity (focal length, or FOV)
	Larger scale means less projection distortion
	This scale should better be tuned offline, and set it only once in runtime
\param scale - default is 1.f, keep perspectivity invariant
	<= 0.f would be treated as illegal input and discard	
*/
void fuSetFocalLengthScale(float scale);
```
__参数:__  

*scale [in]*：焦距调整的比例系数，1.0为默认值。建议取值范围为 0.1 ~ 2.0。

__备注:__  

系数小于等于0为无效输入。

------
#### 2.6 废弃接口
##### fuSetQualityTradeoff  函数

```C
/**
\brief Set the quality-performance tradeoff. 
\param quality is the new quality value. 
       It's a floating point number between 0 and 1.
       Use 0 for maximum performance and 1 for maximum quality.
       The default quality is 1 (maximum quality).
*/
FUNAMA_API void fuSetQualityTradeoff(float quality);
```

------
##### fuTurnOffCamera  函数
```C
/**
\brief Turn off the camera
*/
FUNAMA_API void fuTurnOffCamera();
```

------
##### fuRenderItemsMasked  函数
```C

/**
\brief Generalized interface for rendering a list of items.
	This function needs a GLES 2.0+ context.
\param out_format is the output format
\param out_ptr receives the rendering result, which is either a GLuint texture handle or a memory buffer
	Note that in the texture cases, we will overwrite *out_ptr with a texture we generate.
\param in_format is the input format
\param in_ptr points to the input image, which is either a GLuint texture handle or a memory buffer
\param w specifies the image width
\param h specifies the image height
\param frameid specifies the current frame id. 
	To get animated effects, please increase frame_id by 1 whenever you call this.
\param p_items points to the list of items
\param n_items is the number of items
\param p_masks indicates a list of masks for each item, bitwisely work on certain face
\return a GLuint texture handle containing the rendering result if out_format isn't FU_FORMAT_GL_CURRENT_FRAMEBUFFER
*/
FUNAMA_API int fuRenderItemsMasked(
	int out_format,void* out_ptr,
	int in_format,void* in_ptr,
	int w,int h,int frame_id, int* p_items,int n_items, int* p_masks);
```

------
##### fuGetCameraImageSize  函数
```C	
/**
\brief Get the camera image size
\param pret points to two integers, which receive the size
*/
FUNAMA_API void fuGetCameraImageSize(int* pret);
```

------
##### fuLoadExtendedARData  函数
```C	
/**
\brief Load extended AR data, which is required for high quality AR items
\param data - the pointer to the extended AR data
\param sz - the data size, we use plain int to avoid cross-language compilation issues
\return zero for failure, non-zero for success
*/
int fuLoadExtendedARData(void* data,int sz);
```

------
##### fuLoadAnimModel 函数
加载表情动画模型，并启用表情优化功能。

表情优化功能可以使实时跟踪后得到的表情更加自然生动，但会引入一定表情延迟。
```C
int fuLoadAnimModel(void* dat, int dat_sz);
```
__参数:__  

*dat [in]*：内存指针，指向动画模型文件内容。该文件随SDK分发，文件名为 anim_model.bundle。

*dat_sz [in]*：动画模型文件长度，以字节为单位。

__返回值:__  

返回值 1 代表加载成功，并启用表情优化功能。返回值 0 代表失败。

------
### 3. 输入输出格式列表

##### RGBA 数组
RGBA 格式的图像内存数组。

__数据格式标识符:__

FU_FORMAT_RGBA_BUFFER

__数据内容:__

连续内存空间，长度为 ```w*h*4```。数组元素为```int```，按 RGBA 方式表示颜色信息。

__输入输出支持:__

可输入 / 可输出

__备注:__

由于平台上的内存对齐要求，图像内存空间的实际宽度可能不等于图像的语义宽度。在主运行接口传入图像宽度时，应传入内存实际宽度。

------
##### BGRA 数组
BGRA 格式的图像内存数组。

__数据格式标识符:__

FU_FORMAT_BGRA_BUFFER

__数据内容:__

连续内存空间，长度为 ```w*h*4```。数组元素为```int```，按 BGRA 方式表示颜色信息。

__输入输出支持:__

可输入 / 可输出

__备注:__

由于平台上的内存对齐要求，图像内存空间的实际宽度可能不等于图像的语义宽度。在主运行接口传入图像宽度时，应传入内存实际宽度。

该格式为原生 iOS 的相机数据格式之一。

------
##### RGBA 纹理
RGBA 格式的 OpenGL 纹理。

__数据格式标识符:__

FU_FORMAT_RGBA_TEXTURE

__数据内容:__

一个 ```GLuint```，表示 OpenGL 纹理 ID。

__输入输出支持:__

可输入 / 可输出

------
##### RGBA OES 纹理
RGBA 格式的 OpenGL external OES 纹理。

__数据格式标识符:__

FU_FORMAT_RGBA_TEXTURE_EXTERNAL_OES

__数据内容:__

一个 ```GLuint```，表示 OpenGL external OES 纹理 ID。

__输入输出支持:__

仅输入

__备注:__

该格式为原生安卓相机数据格式之一。

------
##### NV21 数组
NV21 格式的图像内存数组。

__数据格式标识符:__

FU_FORMAT_NV21_BUFFER

__数据内容:__

连续内存，前一段是 Y 数据，长度为 ```w*h```，后一段是 UV 数据，长度为 ```2*((w+1)>>1)```（分辨率是Y的一半，但包含UV两个通道）。两段数据在内存中连续存放。

__输入输出支持:__

可输入 / 可输出

__备注:__
该格式要求UV数据交错存放（如：UVUVUVUV），如UV数据分开存放（UUUUVVVV），请用I420数组格式。

该格式为原生安卓相机数据格式之一。

------
##### NV12 数组
NV12 格式的图像内存数组。

__数据格式标识符:__

FU_FORMAT_NV12_BUFFER

__数据内容:__
结构体 ```TNV12Buffer```，其定义如下。
```c
typedef struct{
	void* p_Y; 
	void* p_CbCr;
	int stride_Y;
	int stride_CbCr;
}TNV12Buffer;
```
__参数:__

*p_Y*：指向 Y 数据的指针。

*p_CbCr*：指向 UV 数据的指针。

*stride_Y*：Y 数据每行的字节长度。

*stride_CbCr*：UV 数据每行的字节长度。

__输入输出支持:__

可输入 / 可输出

__备注:__

该格式与 NV21 数组格式非常类似，只是 UV 数据中 U 和 V 的交错排布相反。不过该格式支持 Y 数据和 UV 数据分别存放，不再要求数据整体连续。
该格式为原生iOS相机数据格式之一。

------
##### I420 数组
I420 格式的图像内存数组。

__数据格式标识符:__

FU_FORMAT_I420_BUFFER

__数据内容:__

连续内存，第一段是 Y 数据，长度为 ```w*h```，第二段是 U 数据，长度为 ```((w+1)>>1)```，第三段是 V 数据，长度为 ```((w+1)>>1)```（后两个通道分辨率是Y的一半）。三段数据在内存中连续存放。

__输入输出支持:__

可输入 / 可输出

__备注:__

该格式和 NV21 数组基本一致，区别在于 U 和 V 数据分别连续存放。

------
##### iOS 双输入
针对iOS原生相机数据的双输入格式。双输入分别指GPU数据输入——OpenGL 纹理，以及CPU内存数据输入——BGRA数组或NV12数组。

相比仅提供内存数组或纹理的单数据输入，该输入模式可以减少一次CPU-GPU间数据传输，可以轻微优化性能（iphone平台上约为2ms）。

__数据格式标识符:__

FU_FORMAT_INTERNAL_IOS_DUAL_INPUT

__数据内容:__
结构体 ```TIOSDualInput```，其定义如下。
```c
typedef struct{
	int format;	
	void* p_BGRA;
	int stride_BGRA;	
	void* p_Y;
	void* p_CbCr;
	int stride_Y;
	int stride_CbCr;	
	int tex_handle;	
}TIOSDualInput;
```

__参数:__

*format*：指示内存数组的数据格式，仅支持 BGRA 和 NV12 两种，分别对应常量 ```FU_IDM_FORMAT_BGRA``` 和 ```FU_IDM_FORMAT_NV12```。

*p_BGRA*：内存数据为 BGRA 格式时，指向内存数据的指针。

*stride_BGRA*：内存数据为 BGRA 格式时，每行图像数据的字节宽度。

*p_Y*：内存数据为 NV12 格式时，指向 Y 通道内存数据的指针。

*p_CbCr*：内存数据为 NV12 格式时，指向 UV 通道内存数据的指针。

*stride_Y*：内存数据为 NV12 格式时，Y 通道内存数据的字节宽度。

*stride_CbCr*：内存数据为 NV12 格式时，UV 通道内存数据的字节宽度。

*tex_handle*：GPU数据的输入，默认为 RGBA 格式的 OpenGL 纹理 ID。

__输入输出支持:__

仅输入

__备注:__

由于在iOS平台上性能优化不大，因此推荐仅在环境中已有 GPU 数据希望复用，或者有意自定义 GPU 数据输入的情况下使用该接口。

------
##### Android 双输入
针对 Android 原生相机数据的双输入格式。双输入分别指GPU数据输入——RGBA / NV21 / I420 格式的 OpenGL 纹理，以及CPU内存数据输入—— NV21/ RGBA / I420 格式的图像内存数组。

相比仅提供内存数组或纹理的单数据输入，该输入模式可以减少一次 CPU-GPU 间数据传输，在 Android 平台上可以显著优化性能，因此**推荐尽可能使用该接口**。

__数据格式标识符:__

FU_FORMAT_ANDROID_DUAL_MODE

__数据内容:__
结构体 ```TAndroidDualMode```，其定义如下。
```c
typedef struct{
	void* p_NV21;
	int tex;
	int flags;
}TAndroidDualMode;
```

__参数:__

*p_NV21*：指向内存图像数据的指针。

*tex*：OpenGL 纹理 ID。

*flags*：扩展功能标识符，所有支持的标识符及其功能如下。多个标识符通过“或”运算符连接。

| 扩展功能标识符                   | 含义                                         |
| -------------------------------- | -------------------------------------------- |
| FU_ADM_FLAG_EXTERNAL_OES_TEXTURE | 传入的纹理为OpenGL external OES 纹理         |
| FU_ADM_FLAG_ENABLE_READBACK      | 开启后将处理结果写回覆盖到传入的内存图像数据 |
| FU_ADM_FLAG_NV21_TEXTURE         | 传入的纹理为 NV21 数据格式                   |
| FU_ADM_FLAG_I420_TEXTURE         | 传入的纹理为 I420 数据格式                   |
| FU_ADM_FLAG_I420_BUFFER          | 传入的内存图像数据为 I420 数据格式           |
| FU_ADM_FALG_RGBA_BUFFER          | 传入的内存图像数据为 RGBA 数据格式           |

__输入输出支持:__
仅输入

------
##### 当前 FBO
指调用主处理接口时当前绑定的 OpenGL FBO。主处理接口可以直接将处理结果绘制到该 FBO 上。

__数据格式标识符:__

FU_FORMAT_GL_CURRENT_FRAMEBUFFER

__数据内容:__

无，数据指针直接传 NULL。

__输入输出支持:__

仅输出

__备注:__

需要在传入 FBO 前完成 FBO 的创建，包括颜色纹理的绑定，该 FBO 需通过 OpenGL 完备性检查。
如果有 3D 绘制内容，需要该 FBO 具备深度缓冲。

------
##### 指定 FBO
可以将外部已经准备好的 OpenGL FBO 传入，不一定在调用主处理接口时作为当前绑定的 FBO。 主处理接口可以直接将处理结果绘制到该 FBO 上。

__数据格式标识符:__

FU_FORMAT_GL_SPECIFIED_FRAMEBUFFER

__数据内容:__
结构体 ```TSPECFBO```，其定义如下。
```c
typedef struct{
	int fbo;
	int tex;
}TSPECFBO;
```

__参数:__

*fbo*：指定的 FBO ID。

*tex*：该 FBO 上绑定的颜色纹理 ID。

__输入输出支持:__

仅输出

__备注:__
需要在传入 FBO 前完成 FBO 的创建，包括颜色纹理的绑定，该 FBO 需通过 OpenGL 完备性检查。
如果有 3D 绘制内容，需要传入 FBO 具备深度缓冲。

------
##### Avatar 驱动信息
特殊的输入数据，不是图像数据，而是人脸驱动信息，用于驱动avatar模型。人脸驱动信息可以在主处理接口执行后获取，也可以外部输入，比如avatar动画录制的信息，或者用户交互产生的信息等。

__数据格式标识符:__

FU_FORMAT_AVATAR_INFO

__数据内容:__
结构体 ```TAvatarInfo```，其定义如下。
```c
typedef struct{	
	float* p_translation;	
	float* p_rotation;
	float* p_expression;
	float* rotation_mode;
	float* pupil_pos;
	int is_valid;
}TAvatarInfo;
```

__参数:__
*p_translation*：指向内存数据的指针，数据为3个float，表示人脸在相机空间的平移。其中，x/y 的单位为图像分辨率，z 是相机空间中人脸的深度。

*p_rotation*：指向内存数据的指针，数据为4个float，表示人头的三位旋转。旋转表示方式为四元数，需要经过换算转化成欧拉角旋转。

*p_expression*：指向内存数据的指针，数据为46个float，表示人脸的表情系数。表情系数的含义请参考《Expression Guide》。

*rotation_mode*：一个int，取值范围为 0-3，表示人脸相对于图像数据的旋转，分别代表旋转0度、90度、180度、270度。

*pupil_pos*：指向内存数据的指针，数据为2个float，表示瞳孔的参数坐标。该坐标本身不具有语义，一般直接从跟踪结果中获取。

*is_valid*：一个int，表示该 avatar 信息是否有效。该值为0的情况下系统不会处理对应 avatar 信息。

__输入输出支持:__

仅输入

__备注:__

该输入模式仅能配合 avatar 道具使用，加载人脸 AR 类道具会导致异常。

该输入模式会简化对传入图像数据的处理，在 avatar 应用情境下性能较高。此外，对于 avatar 的控制更加灵活，可以允许用户自由操控 avatar，如拖动 avatar 转头、触发特定表情等。

------



### 4. 常见问题 

如有使用问题，请联系技术支持。


