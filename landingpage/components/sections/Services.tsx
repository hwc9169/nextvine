'use client'

import { motion, AnimatePresence } from 'framer-motion'
import { Container } from '../ui/Container'
import { Lightbulb, Camera, Brain, FileText } from 'lucide-react'
import Image from 'next/image'
import { useRef, useState, useEffect } from 'react'

interface ServicesProps {
  language: 'ko' | 'en'
}

export function Services({ language }: ServicesProps) {
  const containerRef = useRef<HTMLDivElement>(null)
  const [currentStep, setCurrentStep] = useState(0)
  
  // 누적 스크롤 제어를 위한 상태
  const accumulatedDelta = useRef(0)
  const lastScrollTime = useRef(0)
  const lastDirection = useRef<'up' | 'down' | null>(null)
  const SCROLL_THRESHOLD = 400 // 단계 변경에 필요한 누적 델타값
  const TIME_WINDOW = 3000 // 3초 시간 윈도우

  useEffect(() => {
    const handleSectionChange = (e: CustomEvent) => {
      if (e.detail.sectionIndex === 6) { // Services 섹션
        const { previousSection, direction } = e.detail
        
        // 진입 방향에 따라 다른 초기 단계 설정
        if (direction === 'up') {
          // 아래에서 위로 (Contact → Services): 마지막 단계(2)로 시작
          setCurrentStep(2)
        } else {
          // 위에서 아래로 (Monitoring → Services) 또는 직접 점프: 첫 번째 단계(0)로 시작
          setCurrentStep(0)
        }
      }
    }

    window.addEventListener('sectionChanged', handleSectionChange as EventListener)
    return () => window.removeEventListener('sectionChanged', handleSectionChange as EventListener)
  }, [])

  useEffect(() => {
    const handleWheel = (e: WheelEvent) => {
      // 데스크톱에서만 스크롤 인터랙션 처리 (1024px 이상)
      if (window.innerWidth < 1024) return
      
      // Services 섹션에 있을 때만 처리
      const servicesElement = containerRef.current
      if (!servicesElement) return

      const rect = servicesElement.getBoundingClientRect()
      const isServicesVisible = rect.top <= 0 && rect.bottom >= window.innerHeight

      if (isServicesVisible) {
        const now = Date.now()
        const currentDirection = e.deltaY > 0 ? 'down' : 'up'
        
        e.preventDefault()
        e.stopPropagation()

        // 시간 윈도우 초과 시 누적값 리셋
        if (now - lastScrollTime.current > TIME_WINDOW) {
          accumulatedDelta.current = 0
          lastDirection.current = null
        }
        
        // 방향이 바뀌면 누적값 리셋
        if (lastDirection.current && lastDirection.current !== currentDirection) {
          accumulatedDelta.current = 0
        }
        
        // 현재 스크롤 누적
        accumulatedDelta.current += Math.abs(e.deltaY)
        lastDirection.current = currentDirection
        lastScrollTime.current = now

        // 임계값 도달 시 단계 변경
        if (accumulatedDelta.current >= SCROLL_THRESHOLD) {
          accumulatedDelta.current = 0 // 누적값 리셋
          
          if (currentDirection === 'down') {
            // 아래로 스크롤
            if (currentStep < 2) {
              // 다음 단계로
              setCurrentStep(prev => prev + 1)
            } else {
              // 마지막 단계에서 다음 섹션으로
              setTimeout(() => {
                const event = new CustomEvent('scrollToSection', { detail: { sectionIndex: 7 } })
                window.dispatchEvent(event)
              }, 100)
            }
          } else {
            // 위로 스크롤
            if (currentStep > 0) {
              // 이전 단계로
              setCurrentStep(prev => prev - 1)
            } else {
              // 첫 단계에서 이전 섹션으로
              setTimeout(() => {
                const event = new CustomEvent('scrollToSection', { detail: { sectionIndex: 5 } })
                window.dispatchEvent(event)
              }, 100)
            }
          }
        }
      }
    }

    window.addEventListener('wheel', handleWheel, { passive: false })
    return () => window.removeEventListener('wheel', handleWheel)
  }, [currentStep])
  const content = {
    ko: {
      tag: '어떻게 사용하나요?',
      title: '3단계로 끝나는 간편함',
      subtitle: '복잡한 병원 방문 없이, 집에서 3분만에 우리 아이의 척추 상태를 확인하세요.',
      steps: [
        {
          image: '/images/step01-img.png',
          step: '1',
          title: '스마트 촬영',
          description: '앱이 아이의 자세·각도·조명을 안내해드려 잘못 찍히는 경우를 줄여줍니다.\n안내를 따라 촬영하면, 보다 정확한 측정 결과를 얻을 수 있습니다.',
          tags: ['실시간 가이드 라인', '자세 보정', '조명 체크']
        },
        {
          image: '/images/step02-img.png',
          step: '2',
          title: 'AI 척추 각도 분석',
          description: 'AI가 사진 속 아이의 척추 주요 지점을 인식하여 대략적인 척추 각도와 좌우 균형 상태를 분석해 드립니다.\n이를 통해 변화 추이를 꾸준히 확인할 수 있습니다.',
          tags: ['척추 각도 추정', '균형 분석', '핵심 지점 인식']
        },
        {
          image: '/images/step03-img.png',
          step: '3',
          title: '진행 상황 추적',
          description: '매달 아이의 척추 변화를 기록해 두고, 필요할 때는 전문의와 안전하게 공유할 수 있습니다. 시간이 지남에 따라 아이의 성장 과정과 척추 변화를 한눈에 확인할 수 있습니다.',
          tags: ['월별 기록', '안전한 공유', '성장 추적']
        }
      ]
    },
    en: {
      tag: 'How to Use?',
      title: 'Simple 3-Step Process',
      subtitle: 'Check your child\'s spinal condition at home in just 3 minutes, without complex hospital visits.',
      steps: [
        {
          image: '/images/step01-img.png',
          step: '1',
          title: 'Smart Photography',
          description: 'The app guides your child\'s posture, angle, and lighting to reduce incorrect shots.\nFollowing the guidance provides more accurate measurement results.',
          tags: ['Real-time Guidelines', 'Posture Correction', 'Lighting Check']
        },
        {
          image: '/images/step02-img.png',
          step: '2',
          title: 'AI Spinal Angle Analysis',
          description: 'AI recognizes key spinal points in the photo to analyze approximate spinal angles and left-right balance.\nThis allows you to consistently monitor change trends.',
          tags: ['Spinal Angle Estimation', 'Balance Analysis', 'Key Point Recognition']
        },
        {
          image: '/images/step03-img.png',
          step: '3',
          title: 'Progress Tracking',
          description: 'Record your child\'s spinal changes monthly and securely share with specialists when needed. View your child\'s growth process and spinal changes at a glance over time.',
          tags: ['Monthly Records', 'Secure Sharing', 'Growth Tracking']
        }
      ]
    }
  }

  const currentStepData = content[language].steps[currentStep]

  return (
    <div ref={containerRef} className="min-h-screen lg:h-screen bg-white text-gray-900 relative overflow-hidden">
      <Container size="1600" className="h-full">
        {/* 헤더 (고정) */}
        <div className="absolute top-8 sm:top-12 lg:top-16 left-1/2 transform -translate-x-1/2 text-center z-20 w-full max-w-4xl px-4 pt-4 sm:pt-6 lg:pt-8">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            className="inline-flex items-center justify-center gap-2 mb-6 px-6 py-3 rounded-full"
            style={{ backgroundColor: 'rgba(0, 212, 170, 0.2)' }}
          >
            <Image src="/images/lightbulb.svg" alt="Lightbulb" width={24} height={24} />
            <span className="text-primary-600 font-medium">{content[language].tag}</span>
          </motion.div>
          
          <motion.h2
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1, duration: 0.8 }}
            className="text-2xl sm:text-3xl lg:text-4xl font-bold mb-3 sm:mb-4 leading-tight-custom"
          >
            {content[language].title}
          </motion.h2>
          
          <motion.p
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2, duration: 0.8 }}
            className="text-base sm:text-lg text-gray-600 px-4 sm:px-0"
          >
            {content[language].subtitle}
          </motion.p>
        </div>

        {/* 단계 인디케이터 - 데스크톱에서만 표시 */}
        {/* <div className="hidden lg:block absolute left-1/2 transform -translate-x-1/2 z-20" 
             style={{ top: 'clamp(16rem, 20vh + 8rem, 20rem)' }}>
          <div className="flex space-x-2">
            {content[language].steps.map((_, index) => (
              <div
                key={index}
                className={`w-10 h-1 sm:w-12 rounded-full transition-colors duration-500 ${
                  index <= currentStep ? 'bg-primary-600' : 'bg-gray-200'
                }`}
              />
            ))}
          </div>
        </div> */}

        {/* 메인 컨텐츠 */}
        {/* 데스크톱 버전 - 스크롤 인터랙션 */}
        <div className="hidden lg:flex items-center justify-center h-full pt-40 pb-8">
          <div className="grid grid-cols-2 gap-16 items-center max-w-6xl mx-auto px-4">
            {/* 이미지 (항상 왼쪽) */}
            <div className="relative order-1">
              <AnimatePresence mode="wait">
                <motion.div
                  key={`image-${currentStep}`}
                  initial={{ opacity: 0, scale: 0.9, y: 20 }}
                  animate={{ opacity: 1, scale: 1, y: 0 }}
                  exit={{ opacity: 0, scale: 0.9, y: -20 }}
                  transition={{ 
                    duration: 0.4, 
                    ease: [0.25, 0.46, 0.45, 0.94],
                    opacity: { duration: 0.3 }
                  }}
                  className="relative aspect-[4/3] rounded-2xl overflow-hidden bg-gray-100 max-w-lg mx-auto shadow-lg"
                >
                  <img
                    src={currentStepData.image}
                    alt={currentStepData.title}
                    className="w-full h-full object-contain transition-transform duration-700 hover:scale-105"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/20 via-transparent to-transparent" />
                </motion.div>
              </AnimatePresence>
            </div>

            {/* 텍스트 콘텐츠 (항상 오른쪽) */}
            <div className="relative order-2">
              <AnimatePresence mode="wait">
                <motion.div
                  key={`text-${currentStep}`}
                  initial={{ opacity: 0, y: 30, scale: 0.95 }}
                  animate={{ opacity: 1, y: 0, scale: 1 }}
                  exit={{ opacity: 0, y: -30, scale: 0.95 }}
                  transition={{ 
                    duration: 0.4, 
                    ease: [0.25, 0.46, 0.45, 0.94],
                    delay: 0.05 
                  }}
                  className="bg-white/90 backdrop-blur-sm p-8 rounded-2xl"
                >
                  <motion.div 
                    className="w-12 h-12 bg-primary-600 text-white rounded-full flex items-center justify-center text-xl font-bold mb-6 shadow-lg"
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{ delay: 0.15, duration: 0.3, type: "spring" }}
                  >
                    {currentStepData.step}
                  </motion.div>
                  
                  <motion.h3 
                    className="text-3xl font-bold mb-4 text-gray-900"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.2, duration: 0.3 }}
                  >
                    {currentStepData.title}
                  </motion.h3>
                  
                  <motion.p 
                    className="text-base text-gray-600 leading-relaxed whitespace-pre-line mb-6"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.25, duration: 0.3 }}
                  >
                    {currentStepData.description}
                  </motion.p>

                  <motion.div 
                    className="flex flex-wrap gap-2"
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ delay: 0.3, duration: 0.3 }}
                  >
                    {currentStepData.tags.map((tag, tagIndex) => (
                      <motion.span
                        key={tagIndex}
                        className="px-3 py-1 bg-primary-100 text-primary-700 text-sm rounded-full font-medium"
                        initial={{ opacity: 0, scale: 0.8 }}
                        animate={{ opacity: 1, scale: 1 }}
                        transition={{ delay: 0.35 + tagIndex * 0.05, duration: 0.2 }}
                      >
                        {tag}
                      </motion.span>
                    ))}
                  </motion.div>
                </motion.div>
              </AnimatePresence>
            </div>
          </div>
        </div>

        {/* 모바일/태블릿 버전 - 모든 단계 순차적 표시 */}
        <div className="lg:hidden pt-60 sm:pt-72 pb-12">
          <div className="max-w-4xl mx-auto space-y-12 sm:space-y-16">
            {content[language].steps.map((step, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 40 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: index * 0.1 }}
                viewport={{ once: true, margin: "-50px" }}
                className="space-y-6 sm:space-y-8"
              >
                {/* 이미지 */}
                <div className="relative aspect-[4/3] rounded-xl overflow-hidden bg-gray-100 shadow-lg mx-auto max-w-sm sm:max-w-md">
                  <img
                    src={step.image}
                    alt={step.title}
                    className="w-full h-full object-contain"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/10 via-transparent to-transparent" />
                </div>

                {/* 텍스트 콘텐츠 */}
                <div className="bg-white/90 backdrop-blur-sm p-4 sm:p-6 rounded-xl shadow-sm">
                  <div className="flex items-start gap-4 mb-4">
                    <div className="w-10 h-10 sm:w-12 sm:h-12 bg-primary-600 text-white rounded-full flex items-center justify-center text-lg sm:text-xl font-bold shadow-lg flex-shrink-0">
                      {step.step}
                    </div>
                    <div className="flex-1">
                      <h3 className="text-xl sm:text-2xl font-bold mb-3 text-gray-900">
                        {step.title}
                      </h3>
                    </div>
                  </div>
                  
                  <p className="text-sm sm:text-base text-gray-600 leading-relaxed whitespace-pre-line mb-4 sm:mb-6">
                    {step.description}
                  </p>

                  <div className="flex flex-wrap gap-2">
                    {step.tags.map((tag, tagIndex) => (
                      <span
                        key={tagIndex}
                        className="px-2 py-1 sm:px-3 bg-primary-100 text-primary-700 text-xs sm:text-sm rounded-full font-medium"
                      >
                        {tag}
                      </span>
                    ))}
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>

        {/* 스크롤 힌트 - 데스크톱에서만 표시 */}
        <div className="hidden lg:block absolute bottom-8 left-1/2 transform -translate-x-1/2 text-center text-gray-400 text-sm">
          <div className="flex items-center gap-2">
            <span>{language === 'ko' ? '스크롤하여 단계별로 확인하세요' : 'Scroll to view each step'}</span>
            <div className="w-4 h-6 border border-gray-300 rounded-full flex justify-center">
              <div className="w-1 h-2 bg-gray-300 rounded-full mt-1 animate-bounce" />
            </div>
          </div>
        </div>
      </Container>
    </div>
  )
}