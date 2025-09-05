'use client'

import { motion } from 'framer-motion'
import { Container } from '../ui/Container'
import { useEffect, useState, useRef } from 'react'

interface AboutProps {
  language: 'ko' | 'en'
}

export function About({ language }: AboutProps) {
  const [currentStep, setCurrentStep] = useState(0)
  const [isInternalScrolling, setIsInternalScrolling] = useState(false)
  const [isMobileOrTablet, setIsMobileOrTablet] = useState(false)
  const stepRef = useRef(currentStep)

  const content = {
    ko: {
      steps: [
        {
          text: (
            <>
              스마트폰을 통한 <span className="font-bold" style={{color: '#02D8C2'}}>AI 기반 3D 척추 분석</span>
            </>
          )
        },
        {
          text: '방사선 노출 없이, 병원 방문 없이 가능한 모니터링'
        }
      ]
    },
    en: {
      steps: [
        {
          text: (
            <>
              Smartphone-based <span className="font-bold" style={{color: '#02D8C2'}}>AI-powered 3D spinal analysis</span>
            </>
          )
        },
        {
          text: 'Monitoring possible without radiation exposure or hospital visits'
        }
      ]
    }
  }

  useEffect(() => {
    stepRef.current = currentStep
  }, [currentStep])

  useEffect(() => {
    const checkScreenSize = () => {
      const width = window.innerWidth
      // 모바일/태블릿: 1024px 미만
      setIsMobileOrTablet(width < 1024)
    }
    
    checkScreenSize()
    window.addEventListener('resize', checkScreenSize)
    
    return () => {
      window.removeEventListener('resize', checkScreenSize)
    }
  }, [])

  useEffect(() => {
    const handleWheel = (e: WheelEvent) => {
      // 모바일/태블릿에서는 스크롤 인터랙션 비활성화
      if (isMobileOrTablet) return
      
      // About 섹션이 현재 활성화된 섹션인지 확인
      const aboutSection = document.querySelector('[data-section="about"]') as HTMLElement
      if (!aboutSection) return

      const rect = aboutSection.getBoundingClientRect()
      const isAboutVisible = rect.top <= 0 && rect.bottom >= window.innerHeight

      if (isAboutVisible && !isInternalScrolling) {
        const maxSteps = content[language].steps.length
        
        if (e.deltaY > 0) {
          // 아래로 스크롤
          if (stepRef.current < maxSteps - 1) {
            e.preventDefault()
            e.stopPropagation()
            setIsInternalScrolling(true)
            setCurrentStep(prev => prev + 1)
            
            setTimeout(() => {
              setIsInternalScrolling(false)
            }, 800)
          }
        } else {
          // 위로 스크롤
          if (stepRef.current > 0) {
            e.preventDefault()
            e.stopPropagation()
            setIsInternalScrolling(true)
            setCurrentStep(prev => prev - 1)
            
            setTimeout(() => {
              setIsInternalScrolling(false)
            }, 800)
          }
        }
      }
    }

    const handleKeyDown = (e: KeyboardEvent) => {
      // 모바일/태블릿에서는 키보드 인터랙션 비활성화
      if (isMobileOrTablet) return
      
      const aboutSection = document.querySelector('[data-section="about"]') as HTMLElement
      if (!aboutSection) return

      const rect = aboutSection.getBoundingClientRect()
      const isAboutVisible = rect.top <= 0 && rect.bottom >= window.innerHeight

      if (isAboutVisible && !isInternalScrolling) {
        const maxSteps = content[language].steps.length

        if ((e.key === 'ArrowDown' || e.key === 'PageDown') && stepRef.current < maxSteps - 1) {
          e.preventDefault()
          e.stopPropagation()
          setIsInternalScrolling(true)
          setCurrentStep(prev => prev + 1)
          
          setTimeout(() => {
            setIsInternalScrolling(false)
          }, 800)
        } else if ((e.key === 'ArrowUp' || e.key === 'PageUp') && stepRef.current > 0) {
          e.preventDefault()
          e.stopPropagation()
          setIsInternalScrolling(true)
          setCurrentStep(prev => prev - 1)
          
          setTimeout(() => {
            setIsInternalScrolling(false)
          }, 800)
        }
      }
    }

    // 이벤트를 캡처 단계에서 등록하여 우선순위를 높임
    document.addEventListener('wheel', handleWheel, { passive: false, capture: true })
    document.addEventListener('keydown', handleKeyDown, { capture: true })

    return () => {
      document.removeEventListener('wheel', handleWheel, { capture: true })
      document.removeEventListener('keydown', handleKeyDown, { capture: true })
    }
  }, [language, isInternalScrolling, content, isMobileOrTablet])

  return (
    <div data-section="about" className="min-h-screen lg:h-full flex items-center justify-center relative overflow-hidden overflow-x-hidden">
      {/* Background Video */}
      <video
        autoPlay
        loop
        muted
        playsInline
        className="absolute inset-0 w-full h-full object-cover z-0"
        style={{
          minWidth: '100%',
          minHeight: '100vh',
          width: 'auto',
          height: 'auto'
        }}
      >
        <source src="/video/spine_Pain.mp4" type="video/mp4" />
      </video>
      
      {/* Dark overlay with vignette effect for better text readability */}
      <div className="absolute inset-0 bg-black bg-opacity-30 z-5"></div>
      <div className="absolute inset-0 bg-vignette z-5"></div>
      
      {/* Content */}
      <Container size="full" className="relative z-20">
        <div className="text-center w-full h-screen lg:h-full flex items-center justify-center px-4">
          <div className="relative w-full">
            <motion.div
              initial={{ opacity: 0, y: 50 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 1.0, ease: [0.25, 0.46, 0.45, 0.94] }}
              className="flex flex-col items-center justify-center space-y-6"
            >
              {/* 첫번째 문구 - 제목 */}
              <motion.div
                initial={{ opacity: 0, y: 30 }}
                animate={{ 
                  opacity: isMobileOrTablet ? 1 : (currentStep >= 0 ? 1 : 0),
                  y: isMobileOrTablet ? 0 : (currentStep >= 0 ? 0 : 30)
                }}
                transition={{ 
                  duration: 1.0,
                  delay: 0.2,
                  ease: [0.25, 0.46, 0.45, 0.94]
                }}
              >
                <h1 
                  className="text-2xl sm:text-3xl md:text-4xl lg:text-5xl xl:text-6xl font-bold text-white leading-tight text-center"
                  style={{
                    textShadow: `
                      0 0 10px rgba(255, 255, 255, 0.4),
                      0 0 20px rgba(255, 255, 255, 0.25),
                      1px 1px 2px rgba(0, 0, 0, 0.2)
                    `
                  }}
                >
                  {content[language].steps[0].text}
                </h1>
              </motion.div>

              {/* 두번째 문구 - 부제 */}
              <motion.div
                initial={{ opacity: 0, y: 30 }}
                animate={{ 
                  opacity: isMobileOrTablet ? 1 : (currentStep >= 1 ? 1 : 0),
                  y: isMobileOrTablet ? 0 : (currentStep >= 1 ? 0 : 30)
                }}
                transition={{ 
                  duration: 1.0,
                  delay: isMobileOrTablet ? 0.5 : 0,
                  ease: [0.25, 0.46, 0.45, 0.94]
                }}
              >
                <p 
                  className="text-lg sm:text-xl md:text-2xl lg:text-3xl xl:text-4xl font-medium text-white leading-relaxed text-center"
                  style={{
                    textShadow: `
                      0 0 8px rgba(255, 255, 255, 0.3),
                      0 0 16px rgba(255, 255, 255, 0.2),
                      1px 1px 2px rgba(0, 0, 0, 0.2)
                    `
                  }}
                >
                  {content[language].steps[1].text}
                </p>
              </motion.div>
            </motion.div>
          </div>
        </div>
      </Container>
      
      {/* Step indicator - 데스크톱에서만 표시 */}
      <div className="hidden lg:block absolute bottom-8 left-1/2 transform -translate-x-1/2 z-40">
        <div className="flex space-x-2">
          {content[language].steps.map((_, index) => (
            <div
              key={index}
              className={`w-2 h-2 rounded-full transition-all duration-300 ${
                currentStep === index ? 'bg-primary-400 scale-125' : 'bg-white/40'
              }`}
            />
          ))}
        </div>
      </div>
    </div>
  )
}