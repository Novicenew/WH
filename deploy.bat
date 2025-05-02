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
echo 正在自动处理所有Markdown文件中的图片...

:: 使用PowerShell处理所有Markdown文件中的图片引用
powershell -Command ^"^
Get-ChildItem 'source/_posts' -Filter *.md | ForEach-Object { ^
    $mdFile = $_.FullName; ^
    $folder = $_.BaseName; ^
    $content = Get-Content -Path $mdFile -Raw; ^
    $matches = [regex]::Matches($content, '!\[.*?\]\(((?!http|/img).*?)\)'); ^
    foreach ($match in $matches) { ^
        $imgPath = $match.Groups[1].Value; ^
        $imgName = Split-Path $imgPath -Leaf; ^
        $destFolder = Join-Path 'source\_posts' $folder; ^
        if (!(Test-Path $destFolder)) { ^
            Write-Host ('创建文章图片目录: ' + $destFolder); ^
            New-Item -ItemType Directory -Path $destFolder -Force | Out-Null; ^
        } ^
        $srcFile = Join-Path (Split-Path $mdFile) $imgPath; ^
        $destFile = Join-Path $destFolder $imgName; ^
        if (Test-Path $srcFile) { ^
            Write-Host ('处理图片: ' + $imgPath + ' -> ' + $destFile); ^
            Copy-Item -Path $srcFile -Destination $destFile -Force; ^
        } else { ^
            Write-Host ('图片不存在: ' + $srcFile) -ForegroundColor Yellow; ^
        } ^
    } ^
}^"

echo.
echo 正在启动本地预览...
echo 如果端口 4004 被占用，将自动尝试其他端口
call npx hexo clean
call npx hexo generate
call npx hexo server -p 4004 || call npx hexo server -p 4005 || call npx hexo server -p 4006
goto menu

:clean_generate
echo.
echo 清理并重新生成站点...
call npx hexo clean
call npx hexo generate
echo 完成！
goto menu

:batch_process_images
echo.
echo ========= 批量图片处理 =========
echo 1. 扫描并修复所有文章图片引用
echo 2. 批量优化图片大小(压缩)
echo 3. 批量重命名图片(移除中文和特殊字符)
echo 4. 返回主菜单
echo.
set /p img_choice=请选择操作 (1-4): 

if "%img_choice%"=="1" goto scan_fix_images
if "%img_choice%"=="2" goto optimize_images
if "%img_choice%"=="3" goto rename_images
if "%img_choice%"=="4" goto menu
goto batch_process_images

:scan_fix_images
echo.
echo 正在扫描并修复所有文章的图片引用...

:: 使用PowerShell扫描修复所有Markdown文件中的图片引用
powershell -Command ^"^
Get-ChildItem 'source/_posts' -Filter *.md -Recurse | ForEach-Object { ^
    $mdFile = $_.FullName; ^
    $folder = $_.BaseName; ^
    $content = Get-Content -Path $mdFile -Raw; ^
    $modified = $false; ^
    $matches = [regex]::Matches($content, '!\[(.*?)\]\(((?!http|/img).*?)\)'); ^
    foreach ($match in $matches) { ^
        $imgAlt = $match.Groups[1].Value; ^
        $imgPath = $match.Groups[2].Value; ^
        $imgName = Split-Path $imgPath -Leaf; ^
        $destFolder = Join-Path 'source\_posts' $folder; ^
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
echo 图片扫描和修复完成!
pause
goto batch_process_images

:optimize_images
echo.
echo 注意: 需要已安装ImageMagick才能优化图片
echo 是否已安装ImageMagick? (Y/N)
set /p have_imagemagick=

if /i not "%have_imagemagick%"=="Y" (
    echo.
    echo 请先安装ImageMagick: https://imagemagick.org/script/download.php
    echo 然后重新运行此选项
    pause
    goto batch_process_images
)

echo.
echo 正在批量优化文章图片...
powershell -Command ^"^
Get-ChildItem 'source/_posts' -Directory | ForEach-Object { ^
    $postDir = $_.FullName; ^
    $images = Get-ChildItem $postDir -File -Include *.jpg,*.jpeg,*.png,*.gif; ^
    foreach ($img in $images) { ^
        Write-Host ('优化图片: ' + $img.FullName); ^
        try { ^
            magick $img.FullName -strip -interlace Plane -quality 85%% $img.FullName; ^
            Write-Host ('已优化: ' + $img.Name) -ForegroundColor Green; ^
        } catch { ^
            Write-Host ('优化失败: ' + $img.Name + ' - ' + $_.Exception.Message) -ForegroundColor Red; ^
        } ^
    } ^
}^"

echo.
echo 图片优化完成!
pause
goto batch_process_images

:rename_images
echo.
echo 批量重命名图片（移除中文和特殊字符）...
echo 1. 仅处理全局图片(source/img目录)
echo 2. 处理所有文章图片
echo 3. 返回上级菜单
set /p rename_choice=请选择操作 (1-3): 

if "%rename_choice%"=="1" (
    echo 正在处理全局图片...
    if not exist "source\img" mkdir "source\img"
    powershell -Command ^"^
    Get-ChildItem 'source/img' -File | ForEach-Object { ^
        $oldName = $_.Name; ^
        $newName = $oldName -replace '[^\x00-\x7F]+', '' -replace '[^a-zA-Z0-9.-]', '-'; ^
        if ($oldName -ne $newName) { ^
            Rename-Item $_.FullName -NewName $newName -Force; ^
            Write-Host ('已重命名: ' + $oldName + ' -> ' + $newName) -ForegroundColor Green; ^
        } ^
    }^"
) else if "%rename_choice%"=="2" (
    echo 正在处理所有文章图片...
    powershell -Command ^"^
    Get-ChildItem 'source/_posts' -Directory | ForEach-Object { ^
        $postDir = $_.FullName; ^
        $postName = $_.Name; ^
        $images = Get-ChildItem $postDir -File -Include *.jpg,*.jpeg,*.png,*.gif; ^
        $mdFile = Get-ChildItem 'source/_posts' -Filter ($postName + '.md'); ^
        $content = $null; ^
        if ($mdFile) { $content = Get-Content -Path $mdFile.FullName -Raw; } ^
        foreach ($img in $images) { ^
            $oldName = $img.Name; ^
            $newName = $oldName -replace '[^\x00-\x7F]+', '' -replace '[^a-zA-Z0-9.-]', '-'; ^
            if ($oldName -ne $newName) { ^
                $newPath = Join-Path $postDir $newName; ^
                Rename-Item $img.FullName -NewName $newName -Force; ^
                Write-Host ('已重命名: ' + $oldName + ' -> ' + $newName) -ForegroundColor Green; ^
                if ($content -and $content.Contains('![$oldName]')) { ^
                    $content = $content -replace [regex]::Escape('![')([^]]+)('\](\('+$oldName+'\))'), ('![$1]($newName)'); ^
                    Set-Content -Path $mdFile.FullName -Value $content -Encoding UTF8; ^
                    Write-Host ('已更新文章中的引用: ' + $oldName + ' -> ' + $newName) -ForegroundColor Cyan; ^
                } ^
            } ^
        } ^
    }^"
) else if "%rename_choice%"=="3" (
    goto batch_process_images
)

echo.
echo 图片重命名完成!
pause
goto batch_process_images

:import_clipboard
echo.
set /p post_title=请输入要添加图片的文章标题（不包含.md）: 
if not exist "source/_posts/%post_title%" (
    echo 创建文章图片目录...
    mkdir "source/_posts/%post_title%"
)

set timestamp=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
set timestamp=%timestamp: =0%
set img_path=source/_posts/%post_title%/image_%timestamp%.png

echo 正在从剪贴板导入图片...
powershell -Command ^"^
Add-Type -AssemblyName System.Windows.Forms; ^
$img = [Windows.Forms.Clipboard]::GetImage(); ^
if ($img) { ^
    $img.Save('%img_path%', [System.Drawing.Imaging.ImageFormat]::Png); ^
    echo '图片已保存：%img_path%'; ^
    echo '-----------------------------------'; ^
    echo '在Markdown中使用:'; ^
    echo '![描述](image_%timestamp%.png)'; ^
    echo '-----------------------------------'; ^
} else { ^
    echo '剪贴板中没有图片！' -ForegroundColor Red; ^
}^"

echo.
pause
goto menu

:deploy
echo.
echo ========= 部署选项 =========
echo 1. 部署到GitHub Pages
echo 2. 使用自定义部署命令
echo 3. 返回主菜单
echo.
set /p deploy_choice=请选择操作 (1-3): 

if "%deploy_choice%"=="1" (
    echo 正在部署到GitHub Pages...
    call npx hexo clean
    call npx hexo generate
    call npx hexo deploy
    echo 完成！
    pause
    goto menu
) else if "%deploy_choice%"=="2" (
    echo.
    echo 请输入自定义部署命令:
    set /p custom_cmd=
    call %custom_cmd%
    echo 完成！
    pause
    goto menu
) else if "%deploy_choice%"=="3" (
    goto menu
)
goto deploy

:end
echo.
echo 感谢使用！
pause 