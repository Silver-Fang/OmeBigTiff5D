#pragma once
#include "IOmeTiffReader.h"
#include "ReaderBase.h"
#include "pugixml.hpp"
class OmeTiffReader :public IOmeTiffReader,public ReaderBase
{
private:
	UINT8 iSizeC;
	UINT8 iSizeZ;
	UINT16 iSizeT;
	维度顺序 iDimensionOrder;
	颜色* iChannelColor;
	const char* iFileName;
protected:
	char* iImageDescription;
	//此函数同时还会缓存首个IFD，因此必须在调用之前先分配好IFD像素指针的内存
	virtual void 载入图像描述(pugi::xml_document& XML文档) = 0;
	const BYTE** IFD像素指针;
	UINT32 已缓存数;
	UINT32 缓存全部()override;
	const BYTE* const* GetIFD像素指针()const override;
public:
	virtual ~OmeTiffReader()noexcept;
	void 加载文件(HANDLE 文件句柄)override;
	UINT16 SizeX()const override;
	UINT16 SizeY()const override;
	UINT32 SizeI() override;
	像素类型 PixelType()const override;
	UINT8 BytesPerSample()const override;
	//将*Range参数设为nullptr表示完整读取该维度
	void Read3D(UINT16 XSize, UINT16 YSize, UINT32 ISize, UINT64* XRange, UINT64* YRange, UINT64* IRange, BYTE* BytesOut) override;
	//返回当前文件通道数
	UINT8 SizeC()const override;
	//返回当前文件纵深层数
	UINT8 SizeZ()const override;
	//返回当前文件时间帧数
	UINT16 SizeT()const override;
	//返回当前文件维度顺序
	维度顺序 DimensionOrder()const override;
	//返回某一通道的颜色
	颜色 ChannelColor(UINT8 C)const override;
	//调用方负责分配内存，本函数仅负责将当前各通道颜色写入该内存。内存空间不应小于SizeC。
	void ChannelColor(颜色* Colors)const override;
	//返回图像描述字符串，具有0结尾。只读内部指针，调用方不应当修改其中的字符，否则将发生意外结果。
	const char* ImageDescription()const override;
	//返回文件名字符串，具有0结尾。只读内部指针，调用方不应当修改其中的字符，否则将发生意外结果
	const char* FileName()const override;
	/*
	5D读取函数。给定要读取的目标位置，其每个维度的索引及尺寸。如果要顺序读取某个维度的全部位置，可将该维度索引指针设为nullptr。
	调用方应当负责为BytesOut分配足够的内存，本函数只负责写入该内存。
	*/
	void Read5D(UINT16 XSize, UINT16 YSize, UINT8 CSize, UINT8 ZSize, UINT16 TSize, UINT64* XRange, UINT64* YRange, UINT64* CRange, UINT64* ZRange, UINT64* TRange, BYTE* BytesOut) override;
};