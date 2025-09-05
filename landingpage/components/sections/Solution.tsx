'use client'

import { motion } from 'framer-motion'
import { Container } from '../ui/Container'
import Image from 'next/image'

interface SolutionProps {
  language: 'ko' | 'en'
}

export function Solution({ language }: SolutionProps) {
  const content = {
    ko: {
      title: '집에서 시작해 병원까지 이어지는 안심 솔루션',
      subtitle: '간편한 촬영과 AI 분석, 그리고 전문의 연계까지 한 번에.',
      centerText: '스콜리스캔의 특별함',
      description: 'GNN(Graph Neural Network)이 다양한 대학병원에서 협업하여 수집한 데이터를 해부학적 랜드마크 관계를 학습하여 더 정교한 패턴 분석을 제공합니다.',
      connections: {
        doctorPatient: '정기적 체크',
        patientAi: '리포트 제공',
        aiDoctor: '피드백 제공'
      },
      roles: {
        doctor: '전문의',
        patient: '환자',
        ai: 'AI + 클라우드'
      }
    },
    en: {
      title: 'Comprehensive Solution from Home to Hospital',
      subtitle: 'Simple imaging, AI analysis, and specialist connection all in one.',
      centerText: 'What Makes Scoliscan Special',
      description: 'GNN (Graph Neural Network) learns anatomical landmark relationships from data collected through collaboration with various university hospitals to provide more sophisticated pattern analysis.',
      connections: {
        doctorPatient: 'Regular Check',
        patientAi: 'Report Provision',
        aiDoctor: 'Feedback Provision'
      },
      roles: {
        doctor: 'Specialist',
        patient: 'Patient',
        ai: 'AI + Cloud'
      }
    }
  }

  return (
    <div className="h-full flex items-start justify-center bg-white">
      <Container size="1600" className="pt-12 sm:pt-16 md:pt-20 lg:pt-24">
        <div className="text-center space-y-6 sm:space-y-8">
          {/* Header */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="space-y-4"
          >
            <h2 className="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold text-gray-900 leading-tight px-4">
              {content[language].title}
            </h2>
            <p className="text-base sm:text-lg md:text-xl text-gray-600 leading-relaxed max-w-3xl mx-auto px-4">
              {content[language].subtitle}
            </p>
          </motion.div>

          {/* Triangle Structure */}
          <motion.div
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="relative max-w-2xl mx-auto"
          >
            {/* Triangle Container */}
            <div className="relative w-full h-[350px] md:h-[400px]">
              
              {/* Doctor - Top Center */}
              <motion.div
                initial={{ opacity: 0, scale: 0.8 }}
                whileInView={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.4, delay: 0.3 }}
                className="absolute top-0 left-[calc(50%-3rem)] lg:left-[calc(50%-5rem)]"
                style={{ zIndex: 10 }}
              >
                <div className="relative w-24 h-32 sm:w-28 sm:h-36 md:w-32 md:h-40 lg:w-40 lg:h-48">
                  <Image
                    src="/images/solution-01.png"
                    alt={content[language].roles.doctor}
                    fill
                    className="object-contain"
                  />
                </div>
              </motion.div>

              {/* Patient - Bottom Left */}
              <motion.div
                initial={{ opacity: 0, scale: 0.8 }}
                whileInView={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.4, delay: 0.4 }}
                className="absolute bottom-0 left-[calc(15%-3rem)] lg:left-[calc(20%-4rem)]"
                style={{ zIndex: 10 }}
              >
                <div className="relative w-24 h-32 sm:w-28 sm:h-36 md:w-32 md:h-40 lg:w-40 lg:h-48">
                  <Image
                    src="/images/solution-02.png"
                    alt={content[language].roles.patient}
                    fill
                    className="object-contain"
                  />
                </div>
              </motion.div>

              {/* AI + Cloud - Bottom Right */}
              <motion.div
                initial={{ opacity: 0, scale: 0.8 }}
                whileInView={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.4, delay: 0.5 }}
                className="absolute bottom-0 left-[calc(85%-3rem)] lg:left-[calc(80%-4rem)]"
                style={{ zIndex: 10 }}
              >
                <div className="relative w-24 h-32 sm:w-28 sm:h-36 md:w-32 md:h-40 lg:w-40 lg:h-48">
                  <Image
                    src="/images/solution-03.png"
                    alt={content[language].roles.ai}
                    fill
                    className="object-contain"
                  />
                </div>
              </motion.div>

              {/* Connecting Lines with Animation */}
              <svg className="absolute inset-0 w-full h-full" style={{ zIndex: 5 }}>
                {/* Doctor to Patient - 위 중앙에서 왼쪽 하단으로 */}
                <motion.line
                  initial={{ pathLength: 0 }}
                  whileInView={{ pathLength: 1 }}
                  transition={{ duration: 0.6, delay: 0.6 }}
                  x1="50%"
                  y1="20%"
                  x2="20%"
                  y2="80%"
                  stroke="#0891b2"
                  strokeWidth="4"
                  strokeDasharray="6,6"
                />
                
                {/* Patient to AI - 왼쪽 하단에서 오른쪽 하단으로 */}
                <motion.line
                  initial={{ pathLength: 0 }}
                  whileInView={{ pathLength: 1 }}
                  transition={{ duration: 0.6, delay: 0.7 }}
                  x1="20%"
                  y1="80%"
                  x2="80%"
                  y2="80%"
                  stroke="#0891b2"
                  strokeWidth="4"
                  strokeDasharray="6,6"
                />
                
                {/* AI to Doctor - 오른쪽 하단에서 위 중앙으로 */}
                <motion.line
                  initial={{ pathLength: 0 }}
                  whileInView={{ pathLength: 1 }}
                  transition={{ duration: 0.6, delay: 0.8 }}
                  x1="80%"
                  y1="80%"
                  x2="50%"
                  y2="20%"
                  stroke="#0891b2"
                  strokeWidth="4"
                  strokeDasharray="6,6"
                />

                {/* Gradients */}
                <defs>
                  <linearGradient id="gradient1" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stopColor="#0891b2" />
                    <stop offset="100%" stopColor="#06b6d4" />
                  </linearGradient>
                  <linearGradient id="gradient2" x1="0%" y1="0%" x2="100%" y2="0%">
                    <stop offset="0%" stopColor="#06b6d4" />
                    <stop offset="100%" stopColor="#0891b2" />
                  </linearGradient>
                  <linearGradient id="gradient3" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stopColor="#0891b2" />
                    <stop offset="100%" stopColor="#06b6d4" />
                  </linearGradient>
                </defs>
              </svg>

              {/* Connection Labels */}
              <motion.div
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                transition={{ duration: 0.5, delay: 0.9 }}
                className="absolute top-[45%] left-[25%] transform -translate-x-1/2 -translate-y-1/2"
              >
                <div className="bg-white px-2 py-1 sm:px-3 sm:py-1.5 rounded-md shadow-sm border border-primary-200">
                  <span className="text-xs sm:text-sm font-medium text-primary-700">
                    {content[language].connections.doctorPatient}
                  </span>
                </div>
              </motion.div>

              <motion.div
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                transition={{ duration: 0.5, delay: 1.0 }}
                className="absolute left-1/2 transform -translate-x-1/2"
                style={{ bottom: '7%' }}
              >
                <div className="bg-white px-2 py-1 sm:px-3 sm:py-1.5 rounded-md shadow-sm border border-primary-200">
                  <span className="text-xs sm:text-sm font-medium text-primary-700">
                    {content[language].connections.patientAi}
                  </span>
                </div>
              </motion.div>

              <motion.div
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                transition={{ duration: 0.5, delay: 1.1 }}
                className="absolute top-[45%] right-[25%] transform translate-x-1/2 -translate-y-1/2"
              >
                <div className="bg-white px-2 py-1 sm:px-3 sm:py-1.5 rounded-md shadow-sm border border-primary-200">
                  <span className="text-xs sm:text-sm font-medium text-primary-700">
                    {content[language].connections.aiDoctor}
                  </span>
                </div>
              </motion.div>

              {/* Center Text */}
              <motion.div
                initial={{ opacity: 0, scale: 0.8 }}
                whileInView={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.5, delay: 1.2 }}
                className="absolute ab-center"
                style={{ 
                  zIndex: 15, 
                  top: '50%',
                  left: '50%',
                  transform: 'translate(-50%, 50%) !important' 
                }}
              >
                <div className="bg-gradient-to-r from-primary-500 to-primary-600 text-white px-2 py-1 sm:px-3 sm:py-1.5 md:px-4 md:py-2 rounded-full shadow-lg">
                  <span className="text-xs sm:text-sm md:text-base font-bold">
                    {content[language].centerText}
                  </span>
                </div>
              </motion.div>
            </div>
          </motion.div>

          {/* Description */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 1.3 }}
            className="max-w-4xl mx-auto"
          >
            <p className="text-sm sm:text-base md:text-lg text-gray-600 leading-relaxed bg-gray-50 p-4 sm:p-6 rounded-lg border-l-4 border-primary-500">
              {content[language].description}
            </p>
          </motion.div>
        </div>
      </Container>
    </div>
  )
}