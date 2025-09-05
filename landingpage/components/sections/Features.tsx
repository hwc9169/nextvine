'use client'

import { motion } from 'framer-motion'
import { Container } from '../ui/Container'
import { ArrowRight, X, Check } from 'lucide-react'
import Image from 'next/image'

interface FeaturesProps {
  language: 'ko' | 'en'
}

export function Features({ language }: FeaturesProps) {
  const content = {
    ko: {
      title: '왜 Scoliscan 인가요?',
      subtitle: '반복적인 X-ray 노출을 넘어, 척추 관리의 새로운 기준을 제시합니다.',
      comparison: [
        {
          traditional: '반복적인 X-ray 의존',
          scoliscan: '안전한 방사선 없는 모니터링',
          traditionalDetail: '성장기 아이들의 방사선 노출 위험',
          scoliscanDetail: '안전한 방사선 없는 모니터링'
        },
        {
          traditional: '고가의 특수 장비 필요',
          scoliscan: '빠르고 간단한 평가',
          traditionalDetail: '일부 병원에서만 접근 가능',
          scoliscanDetail: '누구나 따라할 수 있는 촬영 가이드'
        },
        {
          traditional: '지연되고 반응적인 의사결정',
          scoliscan: '조기 발견과 향상된 치료 결과',
          traditionalDetail: '증상이 악화된 뒤에야 확인',
          scoliscanDetail: '전문의가 객관적 데이터로 환자 관리'
        },
        {
          traditional: '환자의 시간·비용 부담과 불편함',
          scoliscan: '통합된 척추 및 자세 인사이트',
          traditionalDetail: '병원 방문과 검사 비용의 반복',
          scoliscanDetail: '앱과 대시보드를 통해 의료진과 함께 관리'
        },
        {
          traditional: '불완전하고 주관적인 모니터링',
          scoliscan: '데이터 기반의 임상적 의사결정',
          traditionalDetail: '촬영 간격이 길고, 변화 기록이 제한적',
          scoliscanDetail: '매달 변화를 추적하고, 필요한 시점에 빠른 대응'
        }
      ]
    },
    en: {
      title: 'Why Scoliscan?',
      subtitle: 'Beyond repetitive X-ray exposure, we present new standards for spinal care.',
      comparison: [
        {
          traditional: 'Dependence on repetitive X-rays',
          scoliscan: 'Safe radiation-free monitoring',
          traditionalDetail: 'Risk of radiation exposure for growing children',
          scoliscanDetail: 'Safe radiation-free monitoring'
        },
        {
          traditional: 'Need for expensive special equipment',
          scoliscan: 'Fast and simple assessment',
          traditionalDetail: 'Accessible only in select hospitals',
          scoliscanDetail: 'Photography guide anyone can follow'
        },
        {
          traditional: 'Delayed and reactive decision-making',
          scoliscan: 'Early detection and improved treatment outcomes',
          traditionalDetail: 'Confirmed only after symptoms worsen',
          scoliscanDetail: 'Specialists manage patients with objective data'
        },
        {
          traditional: 'Patient time, cost burden and inconvenience',
          scoliscan: 'Integrated spinal and posture insights',
          traditionalDetail: 'Repeated hospital visits and examination costs',
          scoliscanDetail: 'Management with medical staff through app and dashboard'
        },
        {
          traditional: 'Incomplete and subjective monitoring',
          scoliscan: 'Data-driven clinical decision making',
          traditionalDetail: 'Long imaging intervals and limited change records',
          scoliscanDetail: 'Track monthly changes and respond quickly when needed'
        }
      ]
    }
  }

  return (
    <div className="min-h-screen lg:h-full flex items-center justify-center bg-white py-12 lg:py-0">
      <Container size="1600">
        <div className="grid lg:grid-cols-[2fr,3fr] gap-8 lg:gap-12 items-center">
          {/* Left: Image */}
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            whileInView={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8 }}
            className="flex justify-center order-2 lg:order-1"
          >
            <div className="relative w-full h-[300px] sm:h-[400px] lg:h-[650px]">
              <Image
                src="/images/Features-image.png"
                alt="Scoliscan Features"
                fill
                className="rounded-[20px] shadow-2xl object-cover"
                priority
              />
            </div>
          </motion.div>

          {/* Right: Content */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            whileInView={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8 }}
            className="space-y-6 lg:space-y-8 order-1 lg:order-2"
          >
            <div className="text-center lg:text-left">
              <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-gray-900 mb-4 leading-tight-custom">
                {content[language].title}
              </h2>
              <p className="text-base sm:text-lg lg:text-xl text-gray-600 leading-relaxed">
                {content[language].subtitle}
              </p>
            </div>

            {/* Comparison Table */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 lg:gap-6 xl:flex xl:justify-start xl:gap-6">
              {/* Traditional Way Section */}
              <div className="bg-[#F2F2F2] rounded-lg p-3 sm:p-4 space-y-2 sm:space-y-3 w-full xl:w-[400px]">
                <h3 className="text-base sm:text-lg font-bold text-gray-800 text-center md:text-left mb-3 lg:mb-4">
                  기존 방식
                </h3>
                <div className="space-y-2">
                  {content[language].comparison.map((item, index) => (
                    <motion.div
                      key={`traditional-${index}`}
                      initial={{ opacity: 0, y: 20 }}
                      whileInView={{ opacity: 1, y: 0 }}
                      transition={{ delay: index * 0.1, duration: 0.6 }}
                      className="bg-white rounded-lg p-2 sm:p-3 text-center"
                    >
                      <h4 className="font-bold text-gray-900 text-sm sm:text-base mb-1">
                        {item.traditional}
                      </h4>
                      <p className="text-xs text-gray-600 leading-relaxed">
                        {item.traditionalDetail}
                      </p>
                    </motion.div>
                  ))}
                </div>
              </div>

              {/* Scoliscan Way Section */}
              <div className="gradient-primary rounded-lg p-3 sm:p-4 space-y-2 sm:space-y-3 w-full xl:w-[400px]">
                <h3 className="text-base sm:text-lg font-bold text-white text-center md:text-left mb-3 lg:mb-4">
                  Scoliscan의 방식
                </h3>
                <div className="space-y-2">
                  {content[language].comparison.map((item, index) => (
                    <motion.div
                      key={`scoliscan-${index}`}
                      initial={{ opacity: 0, y: 20 }}
                      whileInView={{ opacity: 1, y: 0 }}
                      transition={{ delay: index * 0.1, duration: 0.6 }}
                      className="bg-white rounded-lg p-2 sm:p-3 text-center"
                    >
                      <h4 className="font-bold text-primary-600 text-sm sm:text-base mb-1">
                        {item.scoliscan}
                      </h4>
                      <p className="text-xs text-gray-600 leading-relaxed">
                        {item.scoliscanDetail}
                      </p>
                    </motion.div>
                  ))}
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </Container>
    </div>
  )
}