#pragma once
enum class Tiff异常类型
{
	//读取必要信息时超出文件尾
	文件太小,
	//必需标签值未设置
	缺少标签,
	//不符合OME规范
	OME规范,
	不支持的格式,
	文件太大
};