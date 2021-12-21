classdef OmeBigTiff5D<OBT5.OmeTiffReader
	%读写符合5D规范的OME BigTiff文件
	%%
	%5D是在OME BigTiff规范基础上更进一步的严格格式要求，为了实现高性能的读写：
	%
	%标准文件头之后是一个字节79，然后紧跟OME XML图像描述文本。
	%
	%文本之后是首个IFD，两者之间可以有任意大空隙，作为以后扩展图像描述的预留空间
	%
	%除首个IFD具有额外的图像描述，共计12个标签以外，其余每个IFD都有且仅有Tiff规范灰度图像的11个必需标签。这些标签按照固定顺序排列：ImageDescription（仅首IFD有）,
	%StripOffsets, ImageWidth, ImageLength, BitsPerSample, RowsPerStrip,
	%StripByteCounts, Compression, PhotometricInterpretation, XResolution,
	%YResolution, ResolutionUnit
	%
	%所有IFD按顺序紧密排列在一起，中间不留任何空隙。
	% 
	% IFD之后是像素数据，两者之间可以有任意大空隙，作为以后扩展IFD的预留空间。
	% 
	% 所有像素数据也按照IFD顺序紧密排列在一起，中间不留任何空隙。像素数据结束到文件尾可以预留空隙。
	%
	%由于5D规范要求像素数据按顺序紧密排列，整个像素数据段可以看作一个完整的5D数组，进行高性能的5D索引操作和连续内存段对拷。但也因为对结构顺序要求严格，一旦某一结构成员超出预留空间，将不得不向后移动其后所有成员以扩展空间，并修改许多文件内部偏移指针数值，这种操作具有较大的开销。因此使用者应尽可能一次性指定好各维度尺寸信息，避免事后修改。
	%
	%虽然允许修改元数据，但这种修改可能会破坏原有像素值。除非那些像素值已经无用，否则请在修改前将其读出以免丢失。
	%
	%本类还继承了PixelPointer3D和PixelPointer5D两个返回像素指针的函数。在定义它们的基类中，返回的指针指向只读内存段，且不能用于跨IFD拷贝。但对本类对象使用这些函数时，返回的指针指向可写内存，可用于跨IFD拷贝。
	properties(Dependent)
		SizeX(1,1)uint16
		SizeY(1,1)uint16
		PixelType(1,1)OBT5.PixelType
		%OME-TIFF规范要求将文件名信息存储在图像描述中
		FileName(1,:)char
		SizeC(1,1)uint8
		SizeZ(1,1)uint8
		SizeT(1,1)uint8
		%像素数值在磁盘上实际的排列顺序，从低维度到高维度。
		DimensionOrder(1,1)OBT5.DimesionOrder
		ImageDescription(1,:)char
	end
	methods(Access=protected)
		function obj = OmeBigTiff5D(Pointer)
			obj@OBT5.OmeTiffReader(Pointer);
		end
		function ReleasePointer(obj)
			%子类重写此函数可避免重复释放指针，delete无法被重写。
			MexInterface(uint8(OBT5.Internal.ApiCode.DestroyOmeBigTiff5D),obj.Pointer);
		end
	end
	methods(Static)		
		function [obj,Open] = Create(CD,FilePath,varargin)
			%创建类对象
			%% 语法（import OBT5.*）
			% obj=OmeBigTiff5D.Create(CreationDisposition,FilePath);
			% 使用上述语法时，CreationDisposition只能取OpenExisting或TryOpen
			% obj=OmeBigTiff5D.Create(CreationDisposition,FilePath,ImageDescription);
			% obj=OmeBigTiff5D.Create(CreationDisposition,FilePath,SizeX,SizeY,SizeC,SizeZ,SizeT,DimensionOrder,PixelType);
			% 使用上述语法时，CreationDisposition只能取OpenOrCreate或Overwrite
			% [obj,Open]=OmeBigTiff5D.Create(CreationDisposition.OpenOrCreate,FilePath,ImageDescription);
			% [obj,Open]=OmeBigTiff5D.Create(CreationDisposition.OpenOrCreate,FilePath,SizeX,SizeY,SizeC,SizeZ,SizeT,DimensionOrder,PixelType);
			%% 输入参数
			% CreationDisposition(1,1)OBT5.CreationDisposition，详见枚举类文档
			% FilePath(1,:)char，文件路径
			% ImageDescription(1,:)char，OME XML 图像描述，通常从其它 OME TIFF 文件中读取，可以实现元数据的原封拷贝
			% SizeX, SizeY, SizeT(1,1)uint16，图像宽度、高度、时长
			% SizeC, SizeZ(1,1)uint8，图像颜色通道数、层数
			% DimensionOrder(1,1)OBT5.DimensionOrder，维度顺序
			% PixelType(1,1)OBT5.PixelType，像素类型
			%% 返回值
			% obj(1,1)OBT5.OmeBigTiff5D
			% Open(1,1)logical，使用OpenOrCreate时，返回逻辑值，指示图像是否被打开而非新建
			if nargin>8
				varargin{8}=uint8(varargin{8});
				varargin{9}=uint8(varargin{9});
			end
			varargin=[{uint8(OBT5.Internal.ApiCode.CreateOmeBigTiff5D),uint8(CD),FilePath} varargin];
			if CD==OBT5.CreationDisposition.OpenOrCreate
				[POS,Open]=MexInterface(varargin{:});
			else
				POS=MexInterface(varargin{:});
			end
			obj=OmeBigTiff5D(CheckPos(POS));
		end
	end
	methods
		function Size=get.SizeX(obj)
			Size=MexInterface(uint8(OBT5.Internal.ApiCode.GetSizeX),obj.Pointer);
		end
		function set.SizeX(obj,Size)
			MexInterface(uint8(OBT5.Internal.ApiCode.SetSizeX),obj.Pointer,Size);
		end
		function Size=get.SizeY(obj)
			Size=MexInterface(uint8(OBT5.Internal.ApiCode.GetSizeY),obj.Pointer);
		end
		function set.SizeY(obj,Size)
			MexInterface(uint8(OBT5.Internal.ApiCode.SetSizeY),obj.Pointer,Size);
		end
		function Type=get.PixelType(obj)
			Type=OBT5.PixelType(MexInterface(uint8(OBT5.Internal.ApiCode.GetPixelType),obj.Pointer));
		end
		function set.PixelType(obj,Type)
			MexInterface(uint8(OBT5.Internal.ApiCode.SetPixelType),obj.Pointer,uint8(Type));
		end
		function Name=get.FileName(obj)
			Name=MexInterface(uint8(OBT5.Internal.ApiCode.GetFileName),obj.Pointer);
		end
		function set.FileName(obj,Name)
			MexInterface(uint8(OBT5.Internal.ApiCode.SetFileName),obj.Pointer,Name);
		end
		function Size=get.SizeC(obj)
			Size=MexInterface(uint8(OBT5.Internal.ApiCode.GetSizeC),obj.Pointer);
		end
		function set.SizeC(obj,Size)
			MexInterface(uint8(OBT5.Internal.ApiCode.SetSizeC),obj.Pointer,Size);
		end
		function Size=get.SizeZ(obj)
			Size=MexInterface(uint8(OBT5.Internal.ApiCode.GetSizeZ),obj.Pointer);
		end
		function set.SizeZ(obj,Size)
			MexInterface(uint8(OBT5.Internal.ApiCode.SetSizeZ),obj.Pointer,Size);
		end
		function Size=get.SizeT(obj)
			Size=MexInterface(uint8(OBT5.Internal.ApiCode.GetSizeT),obj.Pointer);
		end
		function set.SizeT(obj,Size)
			MexInterface(uint8(OBT5.Internal.ApiCode.SetSizeT),obj.Pointer,Size);
		end
		function Order=get.DimensionOrder(obj)
			Order=OBT5.DimensionOrder(MexInterface(uint8(OBT5.Internal.ApiCode.GetDimensionOrder),obj.Pointer));
		end
		function set.DimensionOrder(obj,Order)
			MexInterface(uint8(OBT5.Internal.ApiCode.SetSizeX),obj.Pointer,uint8(Order));
		end
		function Description=get.ImageDescription(obj)
			Description=MexInterface(uint8(OBT5.Internal.ApiCode.GetImageDescription),obj.Pointer);
		end
		function set.ImageDescription(obj,Description)
			MexInterface(uint8(OBT5.Internal.ApiCode.SetSizeX),obj.Pointer,Description);
		end
		function Color=ChannelColor(obj,varargin)
			%获取或设置全部或指定通道的颜色
			%返回的每个颜色值为uint32类型，可通过typecast函数转换为ABGR分量。例如如果返回颜色值16711935(0xff00ff)，则可计算如下：
			% >>typecast(0xff00ff,'uint8')
			% ans =
			%  1×4 uint8 行向量
			%   255     0   255     0
			% 4个uint8值依次为该颜色的不透明度(Alpha)=255、蓝色分量(Blue)=0、绿色分量(Green)=255、红色分量(Red)=0
			%设置的颜色值也同样需要排列成ABGR向量，然后用typecast转换成uint32类型后交付给本函数进行设置：
			% >>typecast(uint8([255 0 255 0]),'uint32')
			% ans =
			%  uint32
			%   16711935
			%% 语法
			% Colors=obj.ChannelColor; %获取所有通道的颜色
			% Color=obj.ChannelColor(Channel); %获取指定通道的颜色
			% obj.ChannelColor(Colors); %设置所有通道的颜色
			% obj.ChannelColor(Color,Channel); %设置指定通道的颜色
			%% 可选参数
			% Channel(1,1)uint8，要获取/指定哪个通道的颜色？
			% Colors(:,1)uint32，依次设置每个通道的颜色
			% Color(1,1)uint32，要设置的单个通道的颜色
			%% 返回值
			% Color(:,1)uint32，如果指定了Channel参数则为标量，表示指定通道的颜色；否则为列向量，依次排列所有通道的颜色。
			if isa(varargin{1},'uint32')
				MexInterface(uint8(OBT5.Internal.ApiCode.ChannelColor),obj.Pointer,varargin{:});
			else
				Color=MexInterface(uint8(OBT5.Internal.ApiCode.ChannelColor),obj.Pointer,varargin{:});
			end
		end
		function WritePixels5D(obj,AOP,options)
			%向文件写出5D像素数据
			%% 语法
			% obj.WritePixels5D(Data,Name=Value);
			% obj.WritePixels5D(Pointer,Name=Value);
			%% 可选参数
			% Data(:,:,:,:,:)，要写出的5D像素数据，维度顺序必须和目标文件的DimensionOrder一致。
			% Pointer(1,1)uint64，从给定的内存指针读取要写出的数据，维度顺序必须和目标文件的DimensionOrder一致。如果指针来源于OmeBigTiff5D的PixelPointer3D或PixelPointer5D方法，可用于跨IFD拷贝。
			%% 名称值参数
			% X, Y, C, Z, T(1,:)uint64，各维度的写出像素范围。默认依次写满该维度。
			arguments
				obj(1,1)OBT5.OmeBigTiff5D
				AOP(:,:,:,:,:)
				options.X(1,:)uint64=uint64.empty
				options.Y(1,:)uint64=uint64.empty
				options.C(1,:)uint64=uint64.empty
				options.Z(1,:)uint64=uint64.empty
				options.T(1,:)uint64=uint64.empty
			end
			MexInterface(uint8(OBT5.Internal.ApiCode.WritePixels5D),obj.Pointer,options.X,options.Y,options.C,options.Z,options.T,AOP);
		end
	end
end