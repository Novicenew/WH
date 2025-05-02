@echo off
chcp 65001
echo ===== Hexo博客管理系统 =====

:menu
echo.
echo ========= 博客管理菜单 =========
echo 1. 新建文章（支持中文标题）
echo 2. 本地预览（自动处理图片）
echo 3. 清理并重新生成
echo 4. 批量处理文章图片
echo 5. 导入剪贴板图片
echo 6. 部署到网站
echo 7. 退出
echo ==============================
echo.
set /p choice=请选择操作 (1-7): 

if "%choice%"=="1" goto new_post
if "%choice%"=="2" goto server
if "%choice%"=="3" goto clean_generate
if "%choice%"=="4" goto batch_process_images
if "%choice%"=="5" goto import_clipboard
if "%choice%"=="6" goto deploy
if "%choice%"=="7" goto end
goto menu

:new_post
echo.
set /p title=请输入文章标题: 
set /p category=请输入文章分类（直接回车默认为"技术笔记"）: 
if "%category%"=="" set category=技术笔记
set /p tags=请输入文章标签（多个标签用空格分隔）: 

echo.
echo 正在创建文章...
:: 创建分类目录（如果不存在）
if not exist "source/_posts/%category%" mkdir "source/_posts/%category%"

:: 使用Hexo创建文章
call npx hexo new "%title%"

:: 移动文章到对应分类目录
:: 注意：现在我们已经在_config.yml中配置了`:category/:title.md`，所以不再需要手动移动文件
:: 但我们仍然需要确保文章的图片目录存在

:: 创建文章的图片文件夹（在分类目录下）
if not exist "source/_posts/%category%/%title%" mkdir "source/_posts/%category%/%title%"

echo.
echo ========= 文章创建成功！ =========
echo 文章位置：source/_posts/%category%/%title%.md
echo 图片目录：source/_posts/%category%/%title%/
echo.
echo 提示：
echo 1. 可以直接使用中文文件名
echo 2. 图片放在文章专属文件夹中
echo 3. 在文章中引用图片：![描述](图片名.jpg)
echo 4. 使用选项5可以快速导入剪贴板图片
echo ================================
pause
goto menu

:server
echo.
echo 启动本地预览服务器...
echo 正在自动处理所有Markdown文件中的图片...

:: 使用PowerShell处理所有Markdown文件中的图片引用
powershell -Command ^"^
Get-ChildItem 'source/_posts' -Filter *.md -Recurse | ForEach-Object { ^
    $mdFile = $_.FullName; ^
    $folder = $_.BaseName; ^
    $content = Get-Content -Path $mdFile -Raw -Encoding UTF8; ^
    if ($null -eq $content) { ^
        Write-Host ('无法读取文件: ' + $mdFile) -ForegroundColor Red; ^
        return; ^
    } ^
    $modified = $false; ^
    $matches = [regex]::Matches($content, '!\[(.*?)\]\(((?!http|/img).*?)\)'); ^
    foreach ($match in $matches) { ^
        $imgAlt = $match.Groups[1].Value; ^
        $imgPath = $match.Groups[2].Value; ^
        $imgName = Split-Path $imgPath -Leaf; ^
        $categoryFolder = Split-Path (Split-Path $mdFile -Parent) -Leaf; ^
        $destFolder = Join-Path (Join-Path 'source\_posts' $categoryFolder) $folder; ^
        if (!(Test-Path $destFolder)) { ^
            Write-Host ('创建文章图片目录: ' + $destFolder); ^
            New-Item -ItemType Directory -Path $destFolder -Force | Out-Null; ^
        } ^
        $srcFile = Join-Path (Split-Path $mdFile) $imgPath; ^
        $destFile = Join-Path $destFolder $imgName; ^
        $correctPath = $imgName; ^
        if (Test-Path $srcFile) { ^
            Write-Host ('复制图片: ' + $imgPath + ' -> ' + $destFile); ^
            Copy-Item -Path $srcFile -Destination $destFile -Force; ^
            if ($imgPath -ne $correctPath) { ^
                Write-Host ('修复图片引用: ' + $imgPath + ' -> ' + $correctPath) -ForegroundColor Green; ^
                $content = $content -replace [regex]::Escape('!['+ $imgAlt + '](' + $imgPath + ')'), ('![' + $imgAlt + '](' + $correctPath + ')'); ^
                $modified = $true; ^
            } ^
        } else { ^
            $altSrcFile = Join-Path (Split-Path $mdFile) $folder $imgPath; ^
            if (Test-Path $altSrcFile) { ^
                Write-Host ('复制图片(备选路径): ' + $imgPath + ' -> ' + $destFile); ^
                Copy-Item -Path $altSrcFile -Destination $destFile -Force; ^
                if ($imgPath -ne $correctPath) { ^
                    Write-Host ('修复图片引用: ' + $imgPath + ' -> ' + $correctPath) -ForegroundColor Green; ^
                    $content = $content -replace [regex]::Escape('!['+ $imgAlt + '](' + $imgPath + ')'), ('![' + $imgAlt + '](' + $correctPath + ')'); ^
                    $modified = $true; ^
                } ^
            } else { ^
                Write-Host ('图片不存在，无法修复: ' + $imgPath) -ForegroundColor Red; ^
            } ^
        } ^
    } ^
    if ($modified) { ^
        Set-Content -Path $mdFile -Value $content -Encoding UTF8; ^
        Write-Host ('已更新文件: ' + $mdFile) -ForegroundColor Cyan; ^
    } ^
}^"

echo.
echo 启动Hexo服务器，按Ctrl+C停止...
call npx hexo server
goto menu

:clean_generate
echo.
echo 清理并重新生成站点...
call npx hexo clean
call npx hexo generate
echo.
echo 站点生成完成！
pause
goto menu

:batch_process_images
echo.
echo 批量处理文章图片...
call hexo-image-uploader.bat
goto menu

:import_clipboard
echo.
set /p title=请输入文章标题（不包含.md）: 
set /p category=请输入文章所在分类: 
if "%category%"=="" set category=技术笔记

:: 检查文章目录结构
set article_path=source/_posts/%category%/%title%.md
set article_dir=source/_posts/%category%/%title%

if not exist "%article_path%" (
    echo 错误：文章 %title%.md 不存在于分类 %category% 中！
    echo 请确认文章标题和分类是否正确
    pause
    goto menu
)

if not exist "%article_dir%" (
    echo 创建文章图片目录...
    mkdir "%article_dir%"
)

set timestamp=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
set timestamp=%timestamp: =0%
set img_path=%article_dir%/image_%timestamp%.png

echo 正在从剪贴板导入图片...
powershell -Command ^"^
Add-Type -AssemblyName System.Windows.Forms; ^
try { ^
    $img = [Windows.Forms.Clipboard]::GetImage(); ^
    if ($img) { ^
        $img.Save('%img_path%', [System.Drawing.Imaging.ImageFormat]::Png); ^
        echo '图片已保存：%img_path%'; ^
        echo '-----------------------------------'; ^
        echo '在Markdown中使用:'; ^
        echo '![描述](image_%timestamp%.png)'; ^
        echo '-----------------------------------'; ^
        echo '提示：'; ^
        echo '1. 将上面的代码复制到您的Markdown文章中'; ^
        echo '2. 将"描述"替换为您想要的图片描述'; ^
    } else { ^
        echo '剪贴板中没有图片！请先复制图片' -ForegroundColor Red; ^
    } ^
} catch { ^
    echo ('导入图片失败: ' + $_.Exception.Message) -ForegroundColor Red; ^
    echo '可能原因：'; ^
    echo '1. 剪贴板中没有有效图片'; ^
    echo '2. 没有足够的权限写入文件'; ^
    echo '3. 文件路径包含不支持的字符'; ^
}^"

echo.
pause
goto menu

:deploy
echo.
echo 部署到网站...
call npx hexo deploy
echo.
echo 部署完成！
pause
goto menu

:end
echo.
echo 感谢使用！
pause 