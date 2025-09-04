'use client'

import { motion } from 'framer-motion'
import { Button } from '../ui/button'
import { ScrollIndicator } from '../ui/ScrollIndicator'

interface HeroProps {
  language: 'ko' | 'en'
}

export function Hero({ language }: HeroProps) {
  const handleNotifyClick = () => {
    // Contact 섹션(인덱스 4)으로 스크롤
    const event = new CustomEvent('scrollToSection', { 
      detail: { sectionIndex: 4 } 
    })
    window.dispatchEvent(event)
  }

  const content = {
    ko: {
      title: '우리 아이 척추,\n집에서 편안하게 살펴보세요',
      subtitle: 'X-ray 없이 안전하게, AI 기술로 정확하게. 매월 우리 아이의 척추 상태를 체크하고\n전문의와 함께 건강한 성장을 지켜보세요.',
      cta: '출시 알림 받기'
    },
    en: {
      title: 'Monitor Your Child\'s Spine\nComfortably at Home',
      subtitle: 'Safe without X-rays, accurate with AI technology. Check your child\'s spinal condition monthly\nand support healthy growth with specialists.',
      cta: 'Get Launch Notifications'
    }
  }

  return (
    <section className="min-h-screen pb-0 gradient-primary relative overflow-hidden">
      {/* Hero 이미지 - Absolute 위치 (데스크톱: 오른쪽 바닥, 모바일: 하단) */}
      <motion.div
        initial={{ opacity: 0, x: 100 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ delay: 0.3, duration: 0.8 }}
        className="absolute bottom-0 right-12 z-10 lg:block hidden"
      >
        <img 
          src="/images/hero-img.png" 
          alt="Scoliscan App Interface"
          className="h-[80vh] w-auto object-contain object-bottom"
        />
      </motion.div>

      {/* 모바일용 Hero 이미지 - 하단 */}
      <motion.div
        initial={{ opacity: 0, y: 50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3, duration: 0.8 }}
        className="absolute bottom-0 left-1/2 transform -translate-x-1/2 z-10 lg:hidden"
      >
        <img 
          src="/images/hero-img.png" 
          alt="Scoliscan App Interface"
          className="h-[40vh] w-auto object-contain object-bottom"
        />
      </motion.div>

      <div className="container-1600 px-4 sm:px-6 lg:px-8 h-screen relative z-20 flex items-center">
        <div className="w-full max-w-3xl">
      {/* 왼쪽 텍스트 콘텐츠 */}
      <motion.div
        initial={{ opacity: 0, x: -50 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ duration: 0.8 }}
        className="space-y-6 lg:space-y-8"
      >
        {/* 메인 제목 */}
        <motion.h1
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2, duration: 0.8 }}
          className="text-4xl md:text-5xl lg:text-6xl font-bold text-white leading-tight-custom"
        >
          {content[language].title.split('\n').map((line, index) => (
            <span key={index} className="block">
              {line}
            </span>
          ))}
        </motion.h1>

        {/* 부제목 */}
        <motion.p
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4, duration: 0.8 }}
          className="text-lg md:text-xl text-white leading-relaxed max-w-3xl"
        >
          {content[language].subtitle.split('\n').map((line, index) => (
            <span key={index} className="block">
              {line}
            </span>
          ))}
        </motion.p>

        {/* CTA 버튼 */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6, duration: 0.8 }}
        >
          <Button 
            variant="white"
            size="lg"
            onClick={handleNotifyClick}
            className="text-lg px-8 py-4"
          >
            {content[language].cta}
          </Button>
        </motion.div>
      </motion.div>
        </div>
      </div>


      {/* 하단 스크롤 인디케이터 */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1.2, duration: 1 }}
        className="absolute bottom-8 left-1/2 transform -translate-x-1/2 z-30"
      >
        <ScrollIndicator />
      </motion.div>
    </section>
  )
}