@echo off
chcp 65001
echo ===== Hexo Blog Deployment Script =====

:menu
echo.
echo ========= 博客管理菜单 =========
echo 1. 新建文章（支持中文标题）
echo 2. 本地预览（自动处理图片）
echo 3. 清理并重新生成
echo 4. 批量重命名文章图片
echo 5. 导入剪贴板图片
echo 6. 退出
echo ==============================
echo.
set /p choice=请选择操作 (1-6): 

if "%choice%"=="1" goto new_post
if "%choice%"=="2" goto server
if "%choice%"=="3" goto clean_generate
if "%choice%"=="4" goto rename_images
if "%choice%"=="5" goto import_clipboard
if "%choice%"=="6" goto end

:new_post
echo.
set /p title=请输入文章标题: 
set /p category=请输入文章分类（直接回车默认为"技术笔记"）: 
if "%category%"=="" set category=技术笔记
set /p tags=请输入文章标签（多个标签用空格分隔）: 

echo.
echo 正在创建文章...
call npx hexo new "%title%"

:: 创建文章的图片文件夹
if not exist "source/_posts/%title%" mkdir "source/_posts/%title%"

echo.
echo ========= 文章创建成功！ =========
echo 文章位置：source/_posts/%title%.md
echo 图片目录：source/_posts/%title%/
echo.
echo 提示：
echo 1. 可以直接使用中文文件名
echo 2. 图片放在文章专属文件夹中
echo 3. 在文章中引用图片：![描述](图片名.jpg)
echo 4. 使用选项5可以快速导入剪贴板图片
echo ================================
goto menu

:server
echo.
echo 正在检查Markdown文件中的图片...
powershell -Command "Get-ChildItem 'source/_posts' -Filter '*.md' | ForEach-Object { $content = Get-Content $_.FullName; $folder = $_.BaseName; $matches = [regex]::Matches($content, '!\[.*?\]\((.*?)\)'); foreach ($match in $matches) { $imgPath = $match.Groups[1].Value; if ($imgPath -notlike 'http*' -and $imgPath -notlike '/img*') { $srcImg = Join-Path (Split-Path $_.FullName) $imgPath; $destFolder = Join-Path 'source/_posts' $folder; if (!(Test-Path $destFolder)) { New-Item -ItemType Directory -Path $destFolder }; $destImg = Join-Path $destFolder (Split-Path $imgPath -Leaf); if (Test-Path $srcImg) { Copy-Item $srcImg $destImg -Force; Write-Host ('已复制图片: ' + $imgPath + ' -> ' + $destImg) } } } }"

echo.
echo 正在启动本地预览...
echo 如果端口 4000 被占用，将自动尝试端口 4001
call npx hexo clean
call npx hexo generate
call npx hexo server || call npx hexo server -p 4001
goto menu

:clean_generate
echo.
echo 清理并重新生成站点...
call npx hexo clean && npx hexo generate
echo 完成！
goto menu

:rename_images
echo.
echo 批量重命名图片（移除中文和特殊字符）...
echo 请将需要重命名的图片放在 source/img 目录下
set /p confirm=是否继续？(Y/N): 
if /i "%confirm%"=="Y" (
    powershell -Command "Get-ChildItem 'source/img' -File | ForEach-Object { $newName = $_.Name -replace '[^\x00-\x7F]+', '' -replace '[^a-zA-Z0-9.-]', '-'; if ($_.Name -ne $newName) { Rename-Item $_.FullName -NewName $newName -Force; echo ('已重命名: ' + $_.Name + ' -> ' + $newName) } }"
)
goto menu

:import_clipboard
echo.
set /p post_title=请输入要添加图片的文章标题（不包含.md）: 
if not exist "source/_posts/%post_title%" mkdir "source/_posts/%post_title%"
set timestamp=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
set timestamp=%timestamp: =0%
set img_path=source/_posts/%post_title%/image_%timestamp%.png

echo 正在从剪贴板导入图片...
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $img = [Windows.Forms.Clipboard]::GetImage(); if ($img) { $img.Save('%img_path%', [System.Drawing.Imaging.ImageFormat]::Png); echo '图片已保存：%img_path%'; echo '在Markdown中使用：![描述](image_%timestamp%.png)' } else { echo '剪贴板中没有图片！' }"

echo.
goto menu

:end
echo.
echo 感谢使用！
pause 