'use client'

import { motion } from 'framer-motion'
import { Container } from '../ui/container'
import { useEffect, useState, useRef } from 'react'

interface AboutProps {
  language: 'ko' | 'en'
}

export function About({ language }: AboutProps) {
  const [currentStep, setCurrentStep] = useState(0)
  const [isInternalScrolling, setIsInternalScrolling] = useState(false)
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
    const handleWheel = (e: WheelEvent) => {
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
  }, [language, isInternalScrolling, content])

  return (
    <div data-section="about" className="h-full flex items-center justify-center relative overflow-hidden">
      {/* Background Video */}
      <video
        autoPlay
        loop
        muted
        playsInline
        className="absolute inset-0 w-full h-full object-cover"
      >
        <source src="/video/spine_Pain.mp4" type="video/mp4" />
      </video>
      
      {/* Dark overlay with vignette effect for better text readability */}
      <div className="absolute inset-0 bg-black bg-opacity-30"></div>
      <div className="absolute inset-0 bg-vignette"></div>
      
      {/* Content */}
      <Container size="1600" className="relative z-10">
        <div className="text-center w-full h-full flex items-center justify-center px-4">
          <div className="relative w-full max-w-none">
            {content[language].steps.map((step, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 100 }}
                animate={{ 
                  opacity: currentStep === index ? 1 : 0,
                  y: currentStep === index ? 0 : (currentStep > index ? -100 : 100)
                }}
                transition={{ 
                  duration: 1.0,
                  ease: [0.25, 0.46, 0.45, 0.94]
                }}
                className={`absolute inset-0 flex items-center justify-center ${
                  currentStep === index ? 'z-20' : 'z-10'
                }`}
              >
                <h2 
                  className="text-3xl sm:text-4xl md:text-5xl lg:text-6xl xl:text-7xl font-bold text-white leading-tight whitespace-nowrap"
                  style={{
                    textShadow: `
                      0 0 10px rgba(255, 255, 255, 0.4),
                      0 0 20px rgba(255, 255, 255, 0.25),
                      1px 1px 2px rgba(0, 0, 0, 0.2)
                    `
                  }}
                >
                  {step.text}
                </h2>
              </motion.div>
            ))}
          </div>
        </div>
      </Container>
      
      {/* Step indicator */}
      <div className="absolute bottom-8 left-1/2 transform -translate-x-1/2 flex space-x-2 z-30">
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
  )
}