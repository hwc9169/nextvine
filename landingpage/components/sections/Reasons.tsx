'use client'

import { motion } from 'framer-motion'
import { Container } from '../ui/Container'
import { cn } from '@/lib/utils'
import Image from 'next/image'

interface ReasonsProps {
  language: 'ko' | 'en'
}

export function Reasons({ language }: ReasonsProps) {
  const content = {
    ko: {
      tag: '왜 스콜리스캔인가요?',
      title: '선택하는 이유',
      titleHighlight: '스콜리스캔',
      subtitle: '가정에서 신뢰하는 우리 아이 척추건강 파트너',
      reasons: [
        {
          icon: '/images/icon-monitor.svg',
          title: '안전한 모니터링',
          description: '방사선 노출 없이 집에서 안전하게 척추 상태를 확인 가능'
        },
        {
          icon: '/images/icon-doctor.svg',
          title: '전문의 신뢰',
          description: '정형외과 전문의들이 직접 검증한 신뢰할 수 있는 서비스'
        },
        {
          icon: '/images/icon-phone.svg',
          title: '언제 어디서나',
          description: '바쁜 일상 속에서도 스마트폰하나로 간편하게 체크'
        },
        {
          icon: '/images/icon-graph.svg',
          title: '성장 추적',
          description: '아이의 성장과 함께 척추 변화를 체계적으로 관리 가능'
        },
        {
          icon: '/images/icon-money.svg',
          title: '비용 절약',
          description: '정기적인 병원 방문 비용을 절약하면서 지속적인 모니터링'
        },
        {
          icon: '/images/icon-security.svg',
          title: '개인정보 보호',
          description: '아이의 소중한 정보를 암호화하여 안전하게 보관'
        }
      ],
      disclaimer: '* 본 서비스는 의료기기가 아니며 진단 목적으로 사용될 수 없습니다. 교육 및 모니터링 지원만을 목적으로 합니다.\n데이터는 동의 하에 수집되며, 요청 시 삭제할 수 있습니다.'
    },
    en: {
      tag: 'Why Scoliscan?',
      title: 'Choose',
      titleHighlight: 'Scoliscan',
      subtitle: 'Your trusted partner for children\'s spinal health at home',
      reasons: [
        {
          icon: '/images/icon-monitor.svg',
          title: 'Safe Monitoring',
          description: 'Check spinal condition safely at home without radiation exposure'
        },
        {
          icon: '/images/icon-doctor.svg',
          title: 'Medical Trust',
          description: 'Reliable service verified directly by orthopedic specialists'
        },
        {
          icon: '/images/icon-phone.svg',
          title: 'Anytime, Anywhere',
          description: 'Easy check with just a smartphone even in busy daily life'
        },
        {
          icon: '/images/icon-graph.svg',
          title: 'Growth Tracking',
          description: 'Systematic management of spinal changes alongside child\'s growth'
        },
        {
          icon: '/images/icon-money.svg',
          title: 'Cost Savings',
          description: 'Continuous monitoring while saving regular hospital visit costs'
        },
        {
          icon: '/images/icon-security.svg',
          title: 'Privacy Protection',
          description: 'Safely store your child\'s precious information with encryption'
        }
      ],
      disclaimer: '* This service is not a medical device and cannot be used for diagnostic purposes. It is intended solely for educational and monitoring support.\nData is collected with consent and can be deleted upon request.'
    }
  }


  return (
    <div className="min-h-screen lg:h-screen relative overflow-hidden" style={{ backgroundColor: '#1D212E' }}>
      <Container size="1600" className="min-h-screen lg:h-full flex flex-col justify-center py-8 sm:py-12 lg:py-16">
        {/* 헤더 */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          viewport={{ once: false, amount: 0.3 }}
          className="text-center mb-6 sm:mb-8 px-4"
        >
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.1 }}
            viewport={{ once: false, amount: 0.3 }}
            className="inline-flex items-center justify-center gap-2 sm:gap-3 mb-4 sm:mb-6 px-4 sm:px-6 py-2 sm:py-3 rounded-full"
            style={{ backgroundColor: 'rgba(0, 212, 170, 0.2)' }}
          >
            <Image src="/images/star.svg" alt="Star" width={20} height={20} />
            <span className="font-medium text-sm sm:text-base lg:text-lg" style={{ color: '#00D4AA' }}>{content[language].tag}</span>
          </motion.div>
          
          <motion.h2
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2, duration: 0.6 }}
            viewport={{ once: false, amount: 0.3 }}
            className="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold mb-3 sm:mb-4 leading-tight text-white"
          >
            <span style={{ color: '#00D4AA' }}>{content[language].titleHighlight}</span>{' '}
            {content[language].title}
          </motion.h2>
          
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3, duration: 0.6 }}
            viewport={{ once: false, amount: 0.3 }}
            className="text-sm sm:text-base lg:text-xl text-gray-300 px-2 sm:px-0"
          >
            {content[language].subtitle}
          </motion.p>
        </motion.div>

        {/* 이유 카드들 */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 sm:gap-4 mb-6 sm:mb-8 mx-auto px-4 lg:px-0">
          {content[language].reasons.map((reason, index) => {
            return (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 50 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ 
                  duration: 0.6, 
                  delay: index * 0.1, 
                  ease: "easeOut" 
                }}
                viewport={{ once: false, amount: 0.3 }}
                className={cn(
                  "relative py-4 sm:py-6 px-4 sm:px-6 lg:px-10 rounded-2xl sm:rounded-3xl text-center",
                  "bg-white/10 backdrop-blur-sm border border-white/50",
                  "lg:min-w-[450px]"
                )}
              >
                <div className="flex flex-col items-center">
                  <div className={cn(
                    "w-12 h-12 sm:w-16 sm:h-16 rounded-xl sm:rounded-2xl mb-4 sm:mb-6 flex items-center justify-center",
                    "gradient-primary"
                  )}>
                    <Image 
                      src={reason.icon}
                      alt={reason.title}
                      width={24}
                      height={24}
                      className="sm:w-8 sm:h-8"
                    />
                  </div>
                  
                  <h3 className="text-lg sm:text-xl font-bold text-white mb-2 sm:mb-4">
                    {reason.title}
                  </h3>
                  
                  <p className="text-sm sm:text-base text-gray-300 leading-relaxed">
                    {reason.description}
                  </p>
                </div>
              </motion.div>
            )
          })}
        </div>

        {/* 면책 조항 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6, duration: 0.6 }}
          viewport={{ once: false, amount: 0.3 }}
          className="text-center px-4"
        >
          <p className="text-xs sm:text-sm text-gray-400 leading-relaxed whitespace-pre-line max-w-4xl mx-auto">
            {content[language].disclaimer}
          </p>
        </motion.div>
      </Container>
    </div>
  )
}