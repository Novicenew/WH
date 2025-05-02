document.addEventListener('DOMContentLoaded', () => {
  // 如果是首页，创建分类卡片容器
  if (window.location.pathname === '/' || window.location.pathname === '/index.html') {
    const mainContent = document.querySelector('#recent-posts');
    if (mainContent) {
      mainContent.innerHTML = '<div class="category-container" id="category-container"></div>';
      loadCategories();
    }
  }

  // 添加分类卡片的动画和交互效果
  const categoryCards = document.querySelectorAll('.category-card');
  
  // 为每个卡片添加动画延迟，创造错落有致的动画效果
  categoryCards.forEach((card, index) => {
    card.style.animationDelay = `${index * 0.1}s`;
    
    // 添加鼠标移动效果（3D倾斜效果）
    card.addEventListener('mousemove', (e) => {
      const rect = card.getBoundingClientRect();
      const x = e.clientX - rect.left; 
      const y = e.clientY - rect.top;
      
      const xc = rect.width / 2;
      const yc = rect.height / 2;
      
      const dx = x - xc;
      const dy = y - yc;
      
      // 计算倾斜角度，最大倾斜8度
      const tiltX = -(dy / yc) * 8;
      const tiltY = (dx / xc) * 8;
      
      // 应用3D变换
      card.style.transform = `translateY(-8px) perspective(1000px) rotateX(${tiltX}deg) rotateY(${tiltY}deg)`;
    });
    
    // 鼠标离开时恢复原状
    card.addEventListener('mouseleave', () => {
      card.style.transform = '';
      setTimeout(() => {
        card.style.transform = 'translateY(-8px) rotateX(5deg)';
      }, 300);
    });
    
    // 点击效果
    card.addEventListener('click', () => {
      // 添加点击波纹效果
      const ripple = document.createElement('div');
      ripple.className = 'card-ripple';
      card.appendChild(ripple);
      
      // 动画结束后移除波纹元素
      ripple.addEventListener('animationend', () => {
        ripple.remove();
      });
    });
  });
  
  // 为文章卡片添加动画和交互效果
  const articleCards = document.querySelectorAll('.article-sort-item:not(.year)');
  
  articleCards.forEach((card, index) => {
    // 添加渐入动画
    card.style.opacity = '0';
    card.style.transform = 'translateY(20px)';
    card.style.transition = 'all 0.5s cubic-bezier(0.25, 0.8, 0.25, 1)';
    
    // 使用Intersection Observer监测卡片是否进入视口
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          setTimeout(() => {
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
          }, index * 100); // 错落有致地显示
          observer.unobserve(card);
        }
      });
    }, { threshold: 0.1 });
    
    observer.observe(card);
  });
  
  // 为年份标题添加特殊动画
  const yearTitles = document.querySelectorAll('.article-sort-item.year');
  
  yearTitles.forEach((title) => {
    title.style.opacity = '0';
    title.style.transform = 'translateX(-20px)';
    title.style.transition = 'all 0.6s cubic-bezier(0.25, 0.8, 0.25, 1)';
    
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          title.style.opacity = '1';
          title.style.transform = 'translateX(0)';
          observer.unobserve(title);
        }
      });
    }, { threshold: 0.1 });
    
    observer.observe(title);
  });
  
  // 添加卡片波纹样式
  const style = document.createElement('style');
  style.textContent = `
    @keyframes ripple {
      0% {
        transform: scale(0);
        opacity: 1;
      }
      100% {
        transform: scale(4);
        opacity: 0;
      }
    }
    
    .card-ripple {
      position: absolute;
      width: 20px;
      height: 20px;
      background: rgba(255, 255, 255, 0.3);
      border-radius: 50%;
      transform: scale(0);
      left: calc(var(--x, 0) * 1px - 10px);
      top: calc(var(--y, 0) * 1px - 10px);
      animation: ripple 0.8s ease-out;
      pointer-events: none;
      z-index: 10;
    }
  `;
  document.head.appendChild(style);

  // 分类页面详情卡片动画效果
  // 处理文章列表项的动画效果
  const postItems = document.querySelectorAll('.article-sort-item:not(.year)');
  
  // 为每个项目设置延迟动画
  postItems.forEach((item, index) => {
    // 添加自定义属性用于动画延迟计算
    item.style.setProperty('--index', index);
    
    // 添加3D悬浮效果
    item.addEventListener('mousemove', (e) => {
      const rect = item.getBoundingClientRect();
      const x = e.clientX - rect.left; 
      const y = e.clientY - rect.top;
      
      const xc = rect.width / 2;
      const yc = rect.height / 2;
      
      const dx = x - xc;
      const dy = y - yc;
      
      // 设置倾斜角度
      const tiltX = -(dy / yc) * 5;
      const tiltY = (dx / xc) * 5;
      
      item.style.transform = `translateY(-8px) perspective(1000px) rotateX(${tiltX}deg) rotateY(${tiltY}deg)`;
    });
    
    // 鼠标离开时恢复
    item.addEventListener('mouseleave', () => {
      item.style.transform = '';
    });
  });
  
  // 美化分类标题效果
  const categoryTitle = document.querySelector('.article-sort-title');
  if (categoryTitle) {
    // 添加闪光效果
    const shine = document.createElement('div');
    shine.classList.add('title-shine');
    categoryTitle.appendChild(shine);
    
    // 添加闪光样式
    const style = document.createElement('style');
    style.textContent = `
      .title-shine {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: linear-gradient(
          90deg,
          transparent,
          rgba(255, 255, 255, 0.2),
          transparent
        );
        animation: shine 3s infinite;
        pointer-events: none;
      }
      
      @keyframes shine {
        0% {
          transform: translateX(-100%);
        }
        20%, 100% {
          transform: translateX(100%);
        }
      }
    `;
    document.head.appendChild(style);
  }
  
  // 分页导航美化
  const pagination = document.querySelector('.pagination');
  if (pagination) {
    // 为分页按钮添加悬停动画效果
    const pageNumbers = pagination.querySelectorAll('.page-number, .extend');
    pageNumbers.forEach(page => {
      page.addEventListener('mouseenter', () => {
        if (!page.classList.contains('current')) {
          page.style.transform = 'translateY(-3px) scale(1.1)';
          page.style.boxShadow = '0 8px 20px rgba(0, 0, 0, 0.4)';
        }
      });
      
      page.addEventListener('mouseleave', () => {
        if (!page.classList.contains('current')) {
          page.style.transform = '';
          page.style.boxShadow = '';
        }
      });
    });
  }
  
  // 改进页面滚动动画效果
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1 });
  
  // 观察所有文章项目
  postItems.forEach(item => {
    observer.observe(item);
  });
  
  // 添加可见性切换样式
  const visibilityStyle = document.createElement('style');
  visibilityStyle.textContent = `
    .article-sort-item:not(.year) {
      opacity: 0;
      transform: translateY(30px);
      transition: opacity 0.6s ease, transform 0.6s ease;
    }
    
    .article-sort-item:not(.year).visible {
      opacity: 1;
      transform: translateY(0);
    }
  `;
  document.head.appendChild(visibilityStyle);
});

async function loadCategories() {
  const container = document.getElementById('category-container');
  if (!container) return;

  // 定义分类及其描述
  const categories = [
    {
      name: 'stm32学习笔记',
      description: '记录STM32学习过程中的心得体会和技术积累',
      icon: '📚'
    },
    {
      name: '技术笔记',
      description: '分享各类技术学习笔记和经验总结',
      icon: '💻'
    }
  ];

  // 创建分类卡片
  categories.forEach(category => {
    const card = document.createElement('div');
    card.className = 'category-card';
    card.innerHTML = `
      <div class="category-icon">${category.icon}</div>
      <h2 class="category-card-title">${category.name}</h2>
      <p class="category-description">${category.description}</p>
    `;

    // 添加点击事件
    card.addEventListener('click', () => {
      window.location.href = `/categories/${category.name}/`;
    });

    container.appendChild(card);
  });
} 